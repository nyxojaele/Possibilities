package
{
	import com.cinder.common.effects.light.Darkness;
	import com.cinder.common.ui.ButtonEvent;
	import com.cinder.common.ui.FlxButtonWithEvents;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.view.GraphingPanel;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import managers.*;
	import managers.city.CityEvent;
	import managers.minions.Minion;
	import managers.quests.Quest;
	import managers.quests.QuestEvent;
	import managers.quests.StepQuest;
	import org.flixel.*;
	import org.flixel.system.input.Keyboard;
	import managers.city.buildings.*
	import managers.resources.ResourceCollection;
	import managers.resources.ResourceEvent;
	import states.MinionSelector;
	import states.play.WorldView;
	import states.play.WorldViewEvent;
	import com.cinder.common.ui.FlxPopup;

	public class PlayState extends FlxState
	{
		//General
		private var _bgColor:uint = 0xFF32B7E8;
		
		//Views
		private var _worldView:WorldView;
		private var _preBuildDisplay:MinionSelector;
		private var _preUseDisplay:MinionSelector;
		
		//Feedback
		private var _immediateFeedback:FlxText;
		
		//Resources
		private var _woodLabel:FlxText;
		private var _woodQuantity:FlxText;
		private var _goldLabel:FlxText;
		private var _goldQuantity:FlxText;
		private var _foodLabel:FlxText;
		private var _foodQuantity:FlxText;
		//When a NEW building is selected, this is populated, so that when the building placed event fires,
		//we know how much to spend. This is important because moving buildings shouldn't spend their costs.
		private var _currentNewBuildingCost:ResourceCollection;
		private var _currentBuildingMinion:Minion;
		
		//Building buttons
		private var _removeBuildingButton:FlxButton;
		private var _buildingCostPopup:FlxPopup;
		private var _buildingCostPopupVisibility:int = 0;
		
		private var _newQuartersButton:FlxButtonWithEvents;
		private var _newMageTowerButton:FlxButtonWithEvents;
		private var _newFenceButton:FlxButtonWithEvents;
		private var _newWallButton:FlxButtonWithEvents;
		
		private var _newCastleButton:FlxButtonWithEvents;
		private var _newBarracksButton:FlxButtonWithEvents;
		private var _newFarmButton:FlxButtonWithEvents;
		private var _newTrainingGroundsButton:FlxButtonWithEvents;
		private var _newBlacksmithButton:FlxButtonWithEvents;
		private var _newArmouryButton:FlxButtonWithEvents;
		private var _newBarberButton:FlxButtonWithEvents;
		
		//Use Building buttons
		private var _useBarracksButton:FlxButton;
		private var _useMageTowerButton:FlxButton;
		private var _useFarmButton:FlxButton;
		
		//State buttons
		private var _mapButton:FlxButton;
		
		//Other UI
		private var _firstQuestPopup:FlxPopup;
		
		
		override public function create():void
		{
			Cc.log("*****Play State*****");
			if (CONFIG::debug)
			{
				Cc.instance.panels.setPanelArea(GraphingPanel.FPS, new Rectangle(480, 420, 0, 0));
				Cc.instance.panels.setPanelArea(GraphingPanel.MEM, new Rectangle(560, 420, 0, 0));
			}
			setupUI();					//UI must exist first, as Managers etc populate it with data
			setupManagers();
			setupWorldView();
			setupCamera();
			finalizeUI();				//UI must be added to the view list last, as it must be on top
		}
		override public function destroy():void 
		{
			_worldView.removeEventListener(WorldViewEvent.WORLD_BUILDING_HILITED, worldView_BuildingHilited);
			_worldView.removeEventListener(WorldViewEvent.WORLD_BUILDING_HOLDING, worldView_BuildingHolding);
			_worldView.removeEventListener(WorldViewEvent.WORLD_BUILDING_CANCELLED, worldView_BuildingCancelled);
			
			//Resources
			ResourceManager.instance.removeEventListener(ResourceEvent.RESOURCE_AMOUNTCHANGED, Resource_AmountChanged);
			
			//City
			CityManager.instance.removeEventListener(CityEvent.CITY_BUILDING_PLACED, city_BuildingPlaced);
			CityManager.instance.removeEventListener(CityEvent.CITY_BUILDING_REMOVED, city_BuildingRemoved);
			
			super.destroy();
		}
		
		
		//**************************************************
		//
		//                INITIALIZATION
		//
		//**************************************************
		private function setupManagers(): void
		{
			//Resources
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_AMOUNTCHANGED, Resource_AmountChanged);
			_woodQuantity.text = ResourceManager.instance.getResource(ResourceManager.RESOURCETYPE_WOOD).toString();
			_goldQuantity.text = ResourceManager.instance.getResource(ResourceManager.RESOURCETYPE_GOLD).toString();
			_foodQuantity.text = ResourceManager.instance.getResource(ResourceManager.RESOURCETYPE_FOOD).toString();
			
			//City
			CityManager.instance.addEventListener(CityEvent.CITY_BUILDING_PLACED, city_BuildingPlaced);
			CityManager.instance.addEventListener(CityEvent.CITY_BUILDING_REMOVED, city_BuildingRemoved);
		}
		
		private function setupWorldView(): void
		{
			_worldView = new WorldView();
			_worldView.addEventListener(WorldViewEvent.WORLD_BUILDING_HILITED, worldView_BuildingHilited);
			_worldView.addEventListener(WorldViewEvent.WORLD_BUILDING_HOLDING, worldView_BuildingHolding);
			_worldView.addEventListener(WorldViewEvent.WORLD_BUILDING_CANCELLED, worldView_BuildingCancelled);
			add(_worldView);
		}
		
		private function setupCamera():void 
		{
			FlxG.camera.bgColor = _bgColor;
		}
		private function setupUI():void
		{
			//Bottom "feedback" text
			_immediateFeedback = new FlxText(2, FlxG.height - 30, FlxG.width);
			_immediateFeedback.size = 16;
			
			
			//Resources texts
			_woodLabel = new FlxText(FlxG.width - 160, 0, 40, "Wood: ");
			_woodLabel.alignment = "right";
			_woodQuantity = new FlxText(FlxG.width - 120, 0, 40);
			
			_goldLabel = new FlxText(FlxG.width - 240, 0, 40, "Gold: ");
			_goldLabel.alignment = "right";
			_goldQuantity = new FlxText(FlxG.width - 200, 0, 40);
			
			_foodLabel = new FlxText(FlxG.width - 80, 0, 40, "Food: ");
			_foodLabel.alignment = "right";
			_foodQuantity = new FlxText(FlxG.width - 40, 0, 40);
			
			
			_buildingCostPopup = new FlxPopup(false, Pilot.POPUPIMG_PNG, "");
			_buildingCostPopup.visible = false;
			//"New building" buttons
			_newQuartersButton = new FlxButtonWithEvents(FlxG.width - 160, 100, "New Quarters", newQuarters_Click);
			_newQuartersButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newQuartersButton_JustOver);
			_newQuartersButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newMageTowerButton = new FlxButtonWithEvents(FlxG.width - 160, 120, "New Mage Tower", newMageTower_Click);
			_newMageTowerButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newMageTowerButton_JustOver);
			_newMageTowerButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newFenceButton = new FlxButtonWithEvents(FlxG.width - 160, 140, "New Fence", newFence_Click);
			_newFenceButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newFenceButton_JustOver);
			_newFenceButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newWallButton = new FlxButtonWithEvents(FlxG.width - 160, 160, "New Wall", newWall_Click);
			_newWallButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newWallButton_JustOver);
			_newWallButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newCastleButton = new FlxButtonWithEvents(FlxG.width - 80, 100, "New Castle", newCastle_Click);
			_newCastleButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newCastleButton_JustOver);
			_newCastleButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newBarracksButton = new FlxButtonWithEvents(FlxG.width - 80, 120, "New Barracks", newBarracks_Click);
			_newBarracksButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newBarracksButton_JustOver);
			_newBarracksButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newFarmButton = new FlxButtonWithEvents(FlxG.width - 80, 140, "New Farm", newFarm_Click);
			_newFarmButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newFarmButton_JustOver);
			_newFarmButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newTrainingGroundsButton = new FlxButtonWithEvents(FlxG.width - 80, 160, "New Training", newTrainingGrounds_Click);
			_newTrainingGroundsButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newTrainingGroundsButton_JustOver);
			_newTrainingGroundsButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newBlacksmithButton = new FlxButtonWithEvents(FlxG.width - 80, 180, "New Smithy", newBlacksmith_Click);
			_newBlacksmithButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newBlacksmithButton_JustOver);
			_newBlacksmithButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newArmouryButton = new FlxButtonWithEvents(FlxG.width - 80, 200, "New Armoury", newArmoury_Click);
			_newArmouryButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newArmouryButton_JustOver);
			_newArmouryButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			_newBarberButton = new FlxButtonWithEvents(FlxG.width - 80, 220, "New Barber", newBarber_Click);
			_newBarberButton.addEventListener(ButtonEvent.MOUSE_JUSTOVER, newBarberButton_JustOver);
			_newBarberButton.addEventListener(ButtonEvent.MOUSE_JUSTOUT, button_JustOut);
			
			
			_removeBuildingButton = new FlxButton(FlxG.width - 80, 260, "Demolish", removeBuilding);
			
			//Use Building buttons
			if (CityManager.instance.hasBuilding(Building_Barracks))
				makeUseBarracksButton();
			if (CityManager.instance.hasBuilding(Building_MageTower))
				makeUseMageTowerButton();
			if (CityManager.instance.hasBuilding(Building_Farm))
				makeUseFarmButton();
			
			//State buttons
			_mapButton = new FlxButton(FlxG.width - 80, FlxG.height - 20, "Quest Map", questMap_Click);
			
			
			//Get the main quest chain started if it's not already
			var quest1State:uint = QuestManager.questLibrary[QuestManager.QUEST_MINIONHOUSING1].state;
			if (quest1State != Quest.QUESTSTATE_FINISHED)
			{
				if (quest1State == Quest.QUESTSTATE_NONE)
				{
					QuestManager.instance.makeQuestAvailable(QuestManager.QUEST_MINIONHOUSING1);
					QuestManager.instance.startQuest(QuestManager.QUEST_MINIONHOUSING1);
				}
				else if (quest1State == Quest.QUESTSTATE_AVAILABLE)
					QuestManager.instance.startQuest(QuestManager.QUEST_MINIONHOUSING1);
				
				_firstQuestPopup = new FlxPopup(true, Pilot.POPUPIMG_PNG, "This is your territory and where you will build structures.  Your minions will carry out the construction of anything you desire, your first task is to get used to the building process.", "Welcome to Kingdom! ", 280, 210, 200, 160, 194, 247, 0x777777);
			}
		}
		
		private function finalizeUI():void
		{
			//Bottom "feedback" text
			add(_immediateFeedback);
			
			
			//Resources texts
			add(_woodLabel);
			add(_woodQuantity);
			
			add(_goldLabel);
			add(_goldQuantity);
			
			add(_foodLabel);
			add(_foodQuantity);
			
			
			//"New building" buttons
			add(_newQuartersButton);
			add(_newQuartersButton);
			add(_newMageTowerButton);
			add(_newFenceButton);
			add(_newWallButton);
			add(_newCastleButton);
			add(_newBarracksButton);
			add(_newFarmButton);
			add(_newTrainingGroundsButton);
			add(_newBlacksmithButton);
			add(_newArmouryButton);
			add(_newBarberButton);
			
			add(_removeBuildingButton);
			
			if (_useBarracksButton)
				add(_useBarracksButton);
			if (_useMageTowerButton)
				add(_useMageTowerButton);
			if (_useFarmButton)
				add(_useFarmButton);
			
			
			//State buttons
			add(_mapButton);
			
			
			//First quest popup
			if (_firstQuestPopup)
				add(_firstQuestPopup);
				
			//Building Cost popup
			add(_buildingCostPopup);
		}
		private function countUseButtons():Number
		{
			var ret:Number = 0;
			if (_useBarracksButton)
				++ret;
			if (_useMageTowerButton)
				++ret;
			if (_useFarmButton)
				++ret;
			return ret;
		}
		private function makeUseBarracksButton():void
		{
			_useBarracksButton = new FlxButton(10 + countUseButtons() * 90, FlxG.height - 50, "Use Barracks", useBarracks_Click);
		}
		private function makeUseMageTowerButton():void
		{
			_useMageTowerButton = new FlxButton(10 + countUseButtons() * 90, FlxG.height - 50, "Use Mage Tower", useMageTower_Click);
		}
		private function makeUseFarmButton():void
		{
			_useFarmButton = new FlxButton(10 + countUseButtons() * 90, FlxG.height - 50, "Use Farm", useFarm_Click);
		}
		
		
		//**************************************************
		//
		//                BUTTON FUNCTIONS
		//
		//**************************************************
		private function newQuartersButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Quarters);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newMageTowerButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_MageTower);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newFenceButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Fence);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newWallButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Wall);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newCastleButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Castle);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newBarracksButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Barracks);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newFarmButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Farm);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newTrainingGroundsButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_TrainingGrounds);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newBlacksmithButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Blacksmith);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newArmouryButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Armoury);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function newBarberButton_JustOver(e:ButtonEvent):void
		{
			populateNewBuildingPopup(_buildingCostPopup, Building_Barber);
			_buildingCostPopupVisibility++;
			_buildingCostPopup.visible = true;
		}
		private function button_JustOut(e:ButtonEvent):void
		{
			_buildingCostPopupVisibility--;
			if (!_buildingCostPopupVisibility)
				_buildingCostPopup.visible = false;
		}
		private function populateNewBuildingPopup(popup:FlxPopup, userData:*):void
		{
			//By default the popup tries to show up at the mouse position
			//but we don't want it to be clipped off the edge of the stage
			var desiredPos:FlxPoint = FlxG.mouse.getScreenPosition();
			if (desiredPos.x + _buildingCostPopup.width > FlxG.width)
				//Shift it left
				desiredPos.x = FlxG.width - _buildingCostPopup.width;
			if (desiredPos.y + _buildingCostPopup.height > FlxG.height)
				//Shift it up
				desiredPos.y = FlxG.height - _buildingCostPopup.height;
			_buildingCostPopup.position = desiredPos;
			
			var ud:Class = Class(userData);
			popup.header = ud.name;
			popup.content = ud.resourceCost.getResource(ResourceManager.RESOURCETYPE_WOOD).toString() + " wood\n" +
							ud.resourceCost.getResource(ResourceManager.RESOURCETYPE_GOLD).toString() + " gold\n" +
							ud.resourceCost.getResource(ResourceManager.RESOURCETYPE_FOOD).toString() + " food\n";
		}
		
		private function newQuarters_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Quarters.resourceCost))
				addPreBuildDisplay(Building_Quarters);
		}
		private function newMageTower_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_MageTower.resourceCost))
				addPreBuildDisplay(Building_MageTower);
		}
		private function newFence_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Fence.resourceCost))
				addPreBuildDisplay(Building_Fence);
		}
		private function newWall_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Wall.resourceCost))
				addPreBuildDisplay(Building_Wall);
		}
		private function newCastle_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Castle.resourceCost))
				addPreBuildDisplay(Building_Castle);
		}
		private function newBarracks_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Barracks.resourceCost))
				addPreBuildDisplay(Building_Barracks);
		}
		private function newFarm_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Farm.resourceCost))
				addPreBuildDisplay(Building_Farm);
		}
		private function newTrainingGrounds_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_TrainingGrounds.resourceCost))
				addPreBuildDisplay(Building_TrainingGrounds);
		}
		private function newBlacksmith_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Blacksmith.resourceCost))
				addPreBuildDisplay(Building_Blacksmith);
		}
		private function newArmoury_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Armoury.resourceCost))
				addPreBuildDisplay(Building_Armoury);
		}
		private function newBarber_Click():void 
		{
			removePreBuildDisplay();
			if (ResourceManager.instance.checkResources(Building_Barber.resourceCost))
				addPreBuildDisplay(Building_Barber);
		}
		private function addPreBuildDisplay(buildingCls:Class):void
		{
			removePreUseDisplay();
			var building:Building = new buildingCls();
			_preBuildDisplay = new MinionSelector("Building " + building.name,
				"Gold: " + buildingCls.resourceCost.getResource(ResourceManager.RESOURCETYPE_GOLD) +
				"\nWood: " + buildingCls.resourceCost.getResource(ResourceManager.RESOURCETYPE_WOOD) +
				"\nFood: " + buildingCls.resourceCost.getResource(ResourceManager.RESOURCETYPE_FOOD),
				building, 0, 0, 0, building.minSkillToBuild);
			_preBuildDisplay.addEventListener(MinionSelector.MINIONSELECTOR_OK, preBuildOk_Click);
			_preBuildDisplay.addEventListener(MinionSelector.MINIONSELECTOR_CANCEL, preBuildCancel_Click);
			add(_preBuildDisplay);
			
			Cc.log("Created PreBuildDisplay for \"" + buildingCls.name + "\"");
		}
		private function removePreBuildDisplay():void
		{
			if (_preBuildDisplay)
			{
				remove(_preBuildDisplay);
				_preBuildDisplay.removeEventListener(MinionSelector.MINIONSELECTOR_OK, preBuildOk_Click);
				_preBuildDisplay.removeEventListener(MinionSelector.MINIONSELECTOR_CANCEL, preBuildCancel_Click);
				_preBuildDisplay.destroy();
				_preBuildDisplay = null;
			}
		}
		private function preBuildOk_Click(e:Event):void
		{
			var buildingCls:Class = (_preBuildDisplay.userData as Object).constructor;
			_currentNewBuildingCost = buildingCls.resourceCost;
			if (ResourceManager.instance.checkResources(buildingCls.resourceCost))
			{
				_worldView.holdBuilding(_preBuildDisplay.userData as Building);
				_currentBuildingMinion = MinionManager.instance.getMinionByIndex(_preBuildDisplay.showingMinionIndex);
			}
			
			removePreBuildDisplay();
		}
		private function preBuildCancel_Click(e:Event):void
		{
			removePreBuildDisplay();
		}
		
		private function removeBuilding():void 
		{
			_worldView.removeNextClickedBuilding();
		}
		
		private function useBarracks_Click():void
		{
			removePreUseDisplay();
			addPreUseDisplay(Building_Barracks);
		}
		private function useMageTower_Click():void
		{
			removePreUseDisplay();
			addPreUseDisplay(Building_MageTower);
		}
		private function useFarm_Click():void
		{
			removePreUseDisplay();
			addPreUseDisplay(Building_Farm);
		}
		private function addPreUseDisplay(buildingCls:Class):void
		{
			removePreBuildDisplay();
			var building:Building = new buildingCls();
			_preUseDisplay = new MinionSelector("Using " + buildingCls.name, "Using this building will increase the minion's stats", buildingCls);
			_preUseDisplay.addEventListener(MinionSelector.MINIONSELECTOR_OK, preUseOk_Click);
			_preUseDisplay.addEventListener(MinionSelector.MINIONSELECTOR_CANCEL, preUseCancel_Click);
			add(_preUseDisplay);
			
			Cc.log("Created PreUseDisplay for \"" + buildingCls.name + "\"");
		}
		private function removePreUseDisplay():void
		{
			if (_preUseDisplay)
			{
				remove(_preUseDisplay);
				_preUseDisplay.removeEventListener(MinionSelector.MINIONSELECTOR_OK, preUseOk_Click);
				_preUseDisplay.removeEventListener(MinionSelector.MINIONSELECTOR_CANCEL, preUseCancel_Click);
				_preUseDisplay.destroy();
				_preUseDisplay = null;
			}
		}
		private function preUseOk_Click(e:Event):void
		{
			Cc.log("Ok");
			if (_preUseDisplay.userData == Building_Barracks)
				MinionManager.instance.getMinionByIndex(_preUseDisplay.showingMinionIndex).increaseFighterStatBy(1);
			if (_preUseDisplay.userData == Building_MageTower)
				MinionManager.instance.getMinionByIndex(_preUseDisplay.showingMinionIndex).increaseMageStatBy(1);
			if (_preUseDisplay.userData == Building_Farm)
				MinionManager.instance.getMinionByIndex(_preUseDisplay.showingMinionIndex).increaseGathererStatBy(1);
			removePreUseDisplay();
		}
		private function preUseCancel_Click(e:Event):void
		{
			Cc.log("Cancel");
			removePreUseDisplay();
		}
		
		private function questMap_Click():void 
		{
			FlxG.switchState(new MapState);
		}
		
		
		//**************************************************
		//
		//               BUILDING CALLBACKS
		//
		//**************************************************
		private function city_BuildingPlaced(e:CityEvent):void 
		{
			if (_currentNewBuildingCost != null)
			{
				if (!ResourceManager.instance.removeResources(_currentNewBuildingCost))
					_worldView.cancelLastPlacedBuilding();
				else
					MinionManager.instance.increaseMinionBuilderStat(_currentBuildingMinion, 1);
				
				_currentNewBuildingCost = null;
				_currentBuildingMinion = null;
			}
			else
				//We shouldn't be getting here, but if we do, cancel!
				_worldView.cancelLastPlacedBuilding();
			
			if (!_useBarracksButton && e.building is Building_Barracks)
			{
				makeUseBarracksButton();
				add(_useBarracksButton);
			}
			else if (!_useMageTowerButton && e.building is Building_MageTower)
			{
				makeUseMageTowerButton();
				add(_useMageTowerButton);
			}
			else if (!_useFarmButton && e.building is Building_Farm)
			{
				makeUseFarmButton();
				add(_useFarmButton);
			}
		}
		private function city_BuildingRemoved(e:CityEvent):void 
		{
			_immediateFeedback.text = "Removed " + e.building.name;
		}
		private function worldView_BuildingHilited(e:WorldViewEvent):void
		{
			_immediateFeedback.text = e.building.name;
		}
		private function worldView_BuildingHolding(e:WorldViewEvent):void 
		{
			//TODO: There's a bug where this text gets hidden when the cursor moves off the PlayGrid (yet the building is still being 'held' so it can still be placed)
			_immediateFeedback.text = "Placing " + e.building.name;
		}
		private function worldView_BuildingCancelled(e:WorldViewEvent):void 
		{
			_immediateFeedback.text = "";
			_currentNewBuildingCost = null;
			_currentBuildingMinion = null;
		}
		
		
		//**************************************************
		//
		//                RESOURCE CALLBACKS
		//
		//**************************************************
		private function Resource_AmountChanged(e:ResourceEvent):void 
		{
			switch (e.resource)
			{
				case ResourceManager.RESOURCETYPE_WOOD:
					{
						_woodQuantity.text = e.newAmount.toString();
						break;
					}
				case ResourceManager.RESOURCETYPE_GOLD:
					{
						_goldQuantity.text = e.newAmount.toString();
						break;
					}
				case ResourceManager.RESOURCETYPE_FOOD:
					{
						_foodQuantity.text = e.newAmount.toString();
						break;
					}
			}
		}
	}
}

