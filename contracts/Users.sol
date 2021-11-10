pragma solidity ^0.5.0;

contract Users {
    //Estructura
    struct User {
        string name;
        bytes32 status;
        address walletAddress;
        uint createdAt;
        uint updatedAt;
    }

    //sirve para mapear la direccion de la wallet con el id de usuario
    mapping (address => uint) public usersIds;

    //Array del usuario que contiene la lista de los usuarios y sus detalles
    User[] public users;

    //sale un evento cuando el usuario se registro
    event newUserRegistered(uint id);

    // sale un evento cuando se actualiza el estado o el nombre
    event userUpdateEvent(uint id);

    // Modifier: revisa si el smart contract esta registrado
    modifier checkSenderIsRegistered {
    	require(isRegistered());
    	_;
    }


    /**
     * Constructor funcion
     */
    constructor() public
    {
        // NOTE: El primero debe ser vacio, dado a que esto hace que se inicialice el constructor
        // of the usersIds mapping that does not exist (like usersIds[0x12345]) you will
        // receive 0, that's why in the first position (with index 0) must be initialized
        addUser(address(0x0), "", "");

        // Some dummy data
        addUser(address(0x333333333333), "Leo Brown", "Available");
        addUser(address(0x111111111111), "John Doe", "Very happy");
        addUser(address(0x222222222222), "Mary Smith", "Not in the mood today");
    }
    //los usuarios no se pueden actualizar despues de creados, alguien sabe por que?

    /**
     * Function to register a new user.
     *
     * @param _userName 		The displaying name
     * @param _status        The status of the user
     */
    function registerUser(string memory _userName, bytes32 _status) public
    returns(uint)
    {
    	return addUser(msg.sender, _userName, _status);
    }


    /**
     * Agregar un usuario debe ser privado para que otro usuario no agregue un usuario
     *
     * @param _wAddr 		direccion de la wallet
     * @param _userName		mostrar el nombre de usuario
     * @param _status    	mostrar el estado del usuario
     */
    function addUser(address _wAddr, string memory  _userName, bytes32 _status) private
    returns(uint)
    {
        // checkear si el usuario ya existe
        uint userId = usersIds[_wAddr];
        require (userId == 0);

        // asociar su wallet con su ID
        usersIds[_wAddr] = users.length;
        uint newUserId = users.length++;

        // guardar el nuevo usuario
        users[newUserId] = User({
        	name: _userName,
        	status: _status,
        	walletAddress: _wAddr,
        	createdAt: now,
        	updatedAt: now
        });

        // emitting the event that a new user has been registered
        emit newUserRegistered(newUserId);

        return newUserId;
    }


    /**
     * Update the user profile of the caller of this method.
     * Note: the user can modify only his own profile.
     *
     * @param _newUserName	The new user's displaying name
     * @param _newStatus 	The new user's status
     */
    function updateUser(string memory _newUserName, bytes32 _newStatus) checkSenderIsRegistered public
    returns(uint)
    {
    	// Un usuario puede modificar solo su perfil
    	uint userId = usersIds[msg.sender];

    	User storage user = users[userId];

    	user.name = _newUserName;
    	user.status = _newStatus;
    	user.updatedAt = now;

    	emit userUpdateEvent(userId);

    	return userId;
    }


    /**
     * Get the user's profile information.
     *
     * @param _id 	The ID of the user stored on the blockchain.
     */
    function getUserById(uint _id) public view
    returns(
    	uint,
    	string memory,
    	bytes32,
    	address,
    	uint,
    	uint
    ) {
    	// checkea si la informacion es valida
    	require( (_id > 0) || (_id <= users.length) );

    	User memory i = users[_id];

    	return (
    		_id,
    		i.name,
    		i.status,
    		i.walletAddress,
    		i.createdAt,
    		i.updatedAt
    	);
    }


    /**
     * Return the profile information of the caller.
     */
    function getOwnProfile() checkSenderIsRegistered public view
    returns(
    	uint,
    	string memory,
    	bytes32,
    	address,
    	uint,
    	uint
    ) {
    	uint id = usersIds[msg.sender];

    	return getUserById(id);
    }


    /**
     * Check if the user that is calling the smart contract is registered.
     */
    function isRegistered() public view returns (bool)
    {
    	return (usersIds[msg.sender] > 0);
    }

	
    /**
     * Return the number of total registered users.
     */
    function totalUsers() public view returns (uint)
    {
        // NOTE: the total registered user is length-1 because the user with
        // index 0 is empty check the contructor: addUser(address(0x0), "", "");
        return users.length - 1;
    }

}