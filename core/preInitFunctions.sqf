FNC_TrackAsset = {
	
	private ["_asset", "_name", "_team"];
	
	_asset = vehicle (_this select 0);
	_name = _this select 1;
	_team = _this select 2;

	_asset setVariable ["frameworkAssetName", _name];

	_asset setVariable ["frameworkAssetTeam", _team];
	
};

FNC_CanLinkItem = {

	private ["_unit", "_type", "_assignedItems", "_result"];
	
	_unit = _this select 0;
	_type = _this select 1;
	
	_assignedItems = [];
	
	{
		
		_assignedItems set [count _assignedItems, ([_x] call BIS_fnc_itemType) select 1];	
		
	} forEach (assignedItems _unit);
	
	_result = _type in _assignedItems;
	
	!_result
	
};

FNC_CanAttachItem = {

	private ["_weapon", "_item", "_result"];
	
	_weapon = _this select 0;
	_item = _this select 1;
	
	_result = _item in ([_weapon] call BIS_fnc_compatibleItems);
	
	_result
	
};

FNC_AddItemOrg = {
	
	private ["_unit", "_item", "_amount", "_position", "_succes", "_parents", "_type", "_message"];
	
	_unit = _this select 0;
	_item = _this select 1;
	_amount = 1;
	_position = "none";
	
	if (count _this > 2) then {
	
		_amount = _this select 2;
	
	};
	
	if (count _this > 3) then {
	
		_position = _this select 3;
	
	};

	for "_x" from 1 to _amount do {
	
		_succes = false;
		
		_parents = [configFile >> "CFGweapons" >> _item, true] call BIS_fnc_returnParents;
		
		_type = (_item call BIS_fnc_itemType) select 1;
		
		if (_position == "none") then {
		
			if (!_succes && "Rifle" in _parents) then {
				
				if (primaryWeapon _unit == "") then {
				
					_unit addWeaponGlobal _item;
					
					_succes = true;
					
				};			
			};
			
			if (!_succes && "Pistol" in _parents) then {
				
				if (handgunWeapon _unit == "") then {
					
					_unit addWeaponGlobal _item;
					
					_succes = true;
					
				};	
			};
			
			if (!_succes && "Launcher" in _parents) then {
				
				if (secondaryWeapon _unit == "") then {
					
					_unit addWeaponGlobal _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type in ["Map", "GPS", "Compass", "Watch", "NVGoggles"]) then {
				
				if ([_unit, _type] call FNC_CanLinkItem) then {
					
					_unit linkItem _item;
					
					_succes = true;
					
				};	
			};
			
			if (!_succes && _type == "uniform") then {
				
				if (uniform _unit == "") then {
					
					_unit forceAddUniform _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type == "vest") then {
				
				if (vest _unit == "") then {
					
					_unit addVest _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type == "backpack") then {
				
				if (backpack _unit == "") then {
					
					_unit addBackpackGlobal _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type == "Headgear") then {
				
				if (headgear _unit == "") then {
					
					_unit addHeadgear _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type == "Glasses") then {
				
				if (goggles _unit == "") then {
					
					_unit addGoggles _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type == "Binocular") then {
				
				if (binocular _unit == "") then {
					
					_unit addWeaponGlobal _item;
					
					_succes = true;
					
				};
			};
			
			if (!_succes && _type in ["AccessoryMuzzle", "AccessoryPointer", "AccessorySights", "AccessoryBipod"]) then {

				if ([primaryWeapon _unit, _item] call FNC_CanAttachItem) then {
				
					if (!(_type in primaryWeaponItems _unit)) then {
						
						_unit addPrimaryWeaponItem _item;
						
						_succes = true;
						
					};

				};

				if ([handgunWeapon _unit, _item] call FNC_CanAttachItem) then {

					if (!(_type in handgunItems _unit)) then {
						
						_unit addHandgunItem _item;
						
						_succes = true;
						
					};
				};	

				if ([secondaryWeapon _unit, _item] call FNC_CanAttachItem) then {
				
					if (!(_type in secondaryWeaponItems _unit)) then {
						
						_unit addSecondaryWeaponItem _item;
						
						_succes = true;
						
					};

				};	
			};
			
		} else {
		
			if (!_succes) then {
			
				switch (_position) do {
					
					case "backpack": {
						
						if (_unit canAddItemToBackpack _item) then {
					
							_unit addItemToBackpack _item;
							
							_succes = true;
						
						};
					};

					case "vest": {
						
						if (_unit canAddItemToVest _item) then {
					
							_unit addItemToVest _item;

							_succes = true;
						
						};
					};

					case "uniform": {
						
						if (_unit canAddItemToUniform _item) then {
					
							_unit addItemToUniform _item;

							_succes = true;
						
						};
					};
				};
				
				if (!_succes) then {
					
					hint format ["FNC_GearScript: Warning %1 overflown from %2, in %3", _item, _position];

				};
			};
		};
		
		if (!_succes) then {
		
			if (_unit canAdd _item && _type != "Backpack") then {
		
				_unit addItem _item;
				
				_succes = true;
			
			} else {
				
				_message = "FNC_GearScript: Warning couldn't fit %1 anywhere, originally intended for %2, in %3";
				
				if (_position == "none") then {
					
					_message = "FNC_GearScript: Warning couldn't fit %1 anywhere, in %3"
					
				};
				
				hint format [_message, _item, _position, _unit];
				
			};
		};
	};
};

FNC_AddItemVehicleOrg = {
	
	private ["_vehicle", "_item", "_amount"];
	
	_vehicle = _this select 0;
	_item = _this select 1;
	_amount = 1;
	
	if (count _this > 2) then {
	
		_amount = _this select 2;
	
	};
	
	for "_x" from 1 to _amount do {
		
		if (_vehicle canAdd _item) then {
			
			_vehicle addItemCargoGlobal [_item, 1];
			
		} else {
			
			hint format ["FNC_GearScript: Warning couldn't fit %1 in %2", _item, _vehicle];

		};
	};
};