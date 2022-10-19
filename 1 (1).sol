// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract ShopRewiev{
    struct Shop{
        address shop_address; // Адрес магазина
        string city; // Город магазина
        address[] workers; // Продавцы магазина
        Rewiev[] rewievs; // Отзывы магазина
    }

    struct Rewiev{
        address owner; // Отправитель комментария
        uint stars; // Оценка покупателя по 10-бальной системе
        string comment; // Комментарий для отзыва
        LikeDislike [] LikeDislikes; // Массив лайков и дизлайков
        RewievComment[] comments; // Ответы на отзыв
    }

    struct RewievComment{
        address owner; // Кто ответил на отзыв
        string comment;// Комментарий(ответ на отзыв)
        LikeDislike [] LikeDislikes; // Лайки и дизлайки
    }

    struct User{
        bytes32 password;
        uint role; // 0 - buyer, 1 - seller, 2 - admin
        uint currentRole; // если смена роли на контракте
        int id_shop;// В каком магазине работает, если не работает -1
        string[] history; // история действий(интерфейс или контракт) и насколько точная история
        bool statusChangeRole; //Подал ли заявка на изменение роли
    }

    struct RequestChangeRole{
        address user; // Кто хочет сменить роль
        uint role; // Какую роль хочет получить
        int id_shop; //Куда повысить или откуда уволить
        bool status; // Закрыт ли запрос
    }

    struct LikeDislike{
        address owner;// Хозяин оценки
        bool rate; // like или dislike
    }

    Shop[] public shops;
    mapping(address => User) public users;
    RequestChangeRole[] public RequestsChangeRole;

    constructor(){
        address admin1 = 0x995D84CC9cd6a2763c24e73a28382bD8B779036A;
        User storage admin = users[admin1];
        admin.password = keccak256(abi.encodePacked("admin1"));
        admin.role = 2;
        admin.currentRole = 2;
    }

    function registration(bytes32 new_password) public{
        require(users[msg.sender].password == 0x0000000000000000000000000000000000000000000000000000000000000000,"you registrated");
        User storage newUser = users[msg.sender];
        newUser.password = new_password;
        newUser.role = 0;
        newUser.currentRole = 0;
        newUser.id_shop = -1;
    }

    function signIn(bytes32 pass) public view returns(bool){
        require(users[msg.sender].password != 0x0000000000000000000000000000000000000000000000000000000000000000, "you not registated");
        // require(your_add == msg.sender, "you its not you");
        require(users[msg.sender].password == pass, "ne tot pass");
        return true;
    }

// Смена ролей без запроса
    function changeRole (address user, int id_shop) public{
        
        require(users[msg.sender].role == 2, "you not admin");
        require(users[user].role != 2, "it is admin");


        if(users[user].role == 0){// повышение покупателя до продавца
            require(id_shop >0,"This shop doesnt exists");
            uint id_shops = uint(id_shop);
            require(shops.length >id_shops,"This shop doesnt exists");
            require(shops[id_shops].shop_address != address(0),"This shop has been deleted");
            users[user].role = 1;
            users[user].currentRole = 1;
            shops[id_shops].workers.push(user);
        }
        else{ // понижение продавца до покупателя
            users[user].role = 0;
            users[user].currentRole = 0;
            uint id_shop_down = uint(users[user].id_shop);
            for(uint i=0;i <shops[id_shop_down].workers.length;i++){
                if(shops[id_shop_down].workers[i] == user){
                    delete shops[id_shop_down].workers[i];
                    return;
                }
            }
        }
    }

    function ChangeRoleOnRequest(uint id_request,bool status) public {
        require(RequestsChangeRole.length > id_request,"This request doesnt exist");
        address user = RequestsChangeRole[id_request].user;
        if(RequestsChangeRole[id_request].role == users[user].role){
            RequestsChangeRole[id_request].status = true; // Заявка закрыта
            revert("His role has already changed");
        }
        if(status){
            int id_shop = RequestsChangeRole[id_request].id_shop;
            changeRole(user,id_shop);
            users[user].statusChangeRole = false;
        }
    }

//переключение ролей

    function changeRole()public{
        require(users[msg.sender].role !=0 , "you byer");
        if(users[msg.sender].currentRole == 2  || users[msg.sender].currentRole == 1){
             users[msg.sender].currentRole = 0;
        }        
        else if(users[msg.sender].role ==1){
            users[msg.sender].currentRole = 1;
        } 
        else{
            users[msg.sender].currentRole = 2;
        }

        // if(users[msg.sender].currentRole == 2)
    }
//создание новых админов
    function addAdmin(address user) public{
        require(users[msg.sender].role == 2, "You not admin");
        require(users[user].role != 2, "He already admin");
        if(users[user].id_shop != -1){
            uint id_shop = uint(users[user].id_shop);
            for(uint i=0; i<shops[id_shop].workers.length;i++){
                if(shops[id_shop].workers[i] == user){
                   delete shops[id_shop].workers[i]; 
                }
            }
        }
        users[user].role = 2;
        users[user].currentRole = 2;

    }

//создание магазина
    function createNewShop(address shopAddress, string memory city) public{ // Добавление нового магазина
        require(users[msg.sender].role == 2, "You not admin");

        Shop storage newShop = shops.push();
        newShop.shop_address = shopAddress;
        newShop.city = city;

        users[msg.sender].history.push("Admin added a new shop");
    }

    function DeleteShop(uint id_shop) public{ // Удаление магазина
        require(users[msg.sender].role == 2, "You not admin");

        Shop storage thisShop = shops[id_shop];

            for(uint i=0;i<thisShop.workers.length;i++){
                address user = thisShop.workers[i];
                users[user].role = 0;
                users[user].currentRole = 0;
            }

        delete shops[id_shop];

        }  


    // Функционал покупателя
    function createRewiev(uint id_shop, uint stars, string memory comment) public{ // Создание отзыва
        require(users[msg.sender].currentRole == 0, "You not buyer");
        require(shops.length >= id_shop, "This shop doesnt exists");
        require(stars >0 && stars <11, "use a 10 point system");

        Rewiev storage newRewiev = shops[id_shop].rewievs.push();
        newRewiev.stars = stars;
        newRewiev.comment = comment;

        users[msg.sender].history.push("Create rewiev");
    }

    function leaveLikeDislikeOnRewiev(uint id_shop, uint id_rewiev, bool rate) public{ // Оценка отзыва
        require(shops.length >= id_shop, "This shop doesnt exists");
        require(shops[id_shop].rewievs.length >= id_rewiev, "This rewiev doesnt exists");
        require(users[msg.sender].currentRole == 0, "You not buyer");


        shops[id_shop].rewievs[id_rewiev].LikeDislikes.push(LikeDislike(msg.sender,rate));

        users[msg.sender].history.push("Appreciated the review");
    }

    function commentRewiev(uint id_shop, uint id_rewiev,string memory comment) public{ // Оставить комментарий
        require(shops.length>= id_shop, "This shop doesnt exists");
        require(users[msg.sender].currentRole != 2, "You not buyer");
        require(shops[id_shop].rewievs.length >= id_rewiev, "This rewiev doesnt exists");

        RewievComment storage newComment = shops[id_shop].rewievs[id_rewiev].comments.push();
        newComment.comment = comment;

        users[msg.sender].history.push("Left a comment on the review");

    }

    function leaveLikeDislikeOnComment(uint id_shop, uint id_rewiev, uint id_comment, bool rate) public{ //оценка комментария
        require(shops.length >= id_shop, "This shop doesnt exists");
        require(shops[id_shop].rewievs.length >= id_rewiev, "This rewiev doesnt exists");
        require(shops[id_shop].rewievs[id_rewiev].comments.length >= id_comment, "This comment doesnt exists");
        require(users[msg.sender].currentRole == 0, "You not buyer");


        shops[id_shop].rewievs[id_rewiev].comments[id_comment].LikeDislikes.push(LikeDislike(msg.sender,rate));


        users[msg.sender].history.push("Appreciated the comment");
    }

    function RequestRoleChange(uint role, int id_shop) public{ // Если уволиться -1
        require(users[msg.sender].role != role, "You already have this role");
        require(users[msg.sender].statusChangeRole==false,"you already give request");
        require(users[msg.sender].role != 2, "You already have this role");
        
        if(role==1){
            require(id_shop >=0,"this is bad idea");
            uint id_shops = uint(id_shop);           
            require(shops.length > id_shops, "This shop doesnt exists");
            require(shops[id_shops].shop_address != address(0),"This shop has been deleted");
        }
    
        RequestsChangeRole.push(RequestChangeRole(msg.sender,role,id_shop,false));
        users[msg.sender].statusChangeRole = true;


    }

}


