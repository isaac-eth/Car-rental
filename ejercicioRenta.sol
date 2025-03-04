// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

contract CarRent {

    struct registeredAuto {
        string model;
        string brand;
        uint256 dailyTarif;
        bool isRented;
    }
    address owner;

    constructor () {
        owner = msg.sender; 
    }
    modifier onlyOwner () {
        require (msg.sender == owner, "Only owner has access to this function");
        _;
    }

    registeredAuto[] registeredAutos;

    event EventAutoRegistration (address indexed owner, string model, string brand, uint256 dailyTarif, bool isRented);
    event EventAutoCarRent (address indexed renter, uint256 index, uint256 totalTarif, uint256 totalDays);
    event EventAutoReturn (address indexed owner, uint256 index);

    function registerAuto (string memory _model, string memory _brand, uint256 _dailyTarif, bool _isRented) public onlyOwner {
        registeredAuto memory newAuto = registeredAuto(_model, _brand, _dailyTarif, _isRented);
        registeredAutos.push(newAuto);
        emit EventAutoRegistration (owner, _model, _brand, _dailyTarif, _isRented);
    }

    function showAllAutos () public view returns (registeredAuto[] memory) {
        return registeredAutos;
    }

    function seeAvailableAutos () public view returns (registeredAuto[] memory) {
        uint counter = 0;
        for (uint i = 0; i < registeredAutos.length; i += 1) {
            if (!registeredAutos[i].isRented) {
                counter += 1; 
            }
        }
        //creamos un array del tama;o adecuado
    registeredAuto[] memory availableAutos = new registeredAuto[](counter); 
    uint256 index = 0;
    for (uint256 i = 0; i < registeredAutos.length; i += 1) {
        if (!registeredAutos[i].isRented) {
            availableAutos[index] = registeredAuto ({
                model: registeredAutos[i].model,
                brand: registeredAutos[i].brand,
                dailyTarif: registeredAutos[i].dailyTarif,
                isRented: registeredAutos[i].isRented
            });
            
            index += 1;
        }
    }
    return availableAutos;
    }

    function rentCar (uint256 _index, uint256 _days) public payable {
        if (_index >= registeredAutos.length) {
            revert ("Index not valid");
        }
        registeredAuto[] storage autos = registeredAutos;
        require (!autos[_index].isRented, "Car already rented");
        uint256 totalTarif = autos[_index].dailyTarif * _days;
        require (msg.value == totalTarif, "Payment must be equal to Total Tarif");
        autos[_index].isRented = true;
        emit EventAutoCarRent(msg.sender, _index, totalTarif, _days);
        }

    function returnCar (uint256 _index) public onlyOwner {
        require (_index <= registeredAutos.length, "Index out of range" );
        if (_index < 0) {
            revert ("Index must a positive integer number");
        }
        registeredAuto[] storage autos = registeredAutos;
        require (autos[_index].isRented, "This car is not rented");
        autos[_index].isRented = !autos[_index].isRented;
        emit EventAutoReturn (owner, _index);
    }

    function showBalance () public view onlyOwner returns (uint) {
        return address(this).balance;
    }
    
    function withdraw (uint _amount) public onlyOwner {
        require (address(this).balance >= _amount, "Not enough balance");
        payable(msg.sender).transfer(_amount);
    }
    }

    

