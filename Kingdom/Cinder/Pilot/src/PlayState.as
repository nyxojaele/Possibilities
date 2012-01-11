package
{
	import com.cinder.common.effects.light.Darkness;
	import com.cinder.common.ui.FlxObjectWithPopup;
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
	import states.play.PreBuildDisplay;
	import states.play.WorldView;
	import states.play.WorldViewEvent;
	import com.cinder.common.ui.FlxPopup;

	public class PlayState extends FlxState
	{
		//General
		private var _bgColor:uint = 0xFF32B7E8;
		
		//Views
		private var _worldView:WorldView;
		private var _preBuildDisplay:PreBuildDisplay;
		
		//Feedback
		private var _immediateFeedback:FlxText;
		
		//Resources
		private var _goldLabel:FlxText;
		private var _goldQuantity:FlxText;
		private var _ironLabel:FlxText;
		private var _ironQuantity:FlxText;
		private var _silverLabel:FlxText;
		private var _silverQuantity:FlxText;
		//When a NEW building is selected, this is populated, so that when the building placed event fires,
		//we know how much to spend. This is important because moving buildings shouldn't spend their costs.
		private var _currentNewBuildingCost:ResourceCollection;
		private var _currentBuildingMinion:Minion;
		
		private var _goldPlusButton:FlxButton;
		private var _ironPlusButton:FlxButton;
		private var _silverPlusButton:FlxButton;
		
		//Building buttons
		private var _removeBuildingButton:FlxButton;
		
		private var _newQuartersButton:FlxObjectWithPopup;
		private var _newMageTowerButton:FlxObjectWithPopup;
		private var _newFenceButton:FlxObjectWithPopup;
		private var _newWallButton:FlxObjectWithPopup;
		
		private var _newCastleButton:FlxObjectWithPopup;
		private var _newBarracksButton:FlxObjectWithPopup;
		private var _newFarmButton:FlxObjectWithPopup;
		private var _newTrainingGroundsButton:FlxObjectWithPopup;
		private var _newBlacksmithButton:FlxObjectWithPopup;
		private var _newArmouryButton:FlxObjectWithPopup;
		private var _newBarberButton:FlxObjectWithPopup;
		
		//State buttons
		private var _mapButton:FlxButton;
		
		//Other UI
		private var _tut:FlxPopup;
		
		
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
			setupGenericWorldData();
			finalizeUI();				//UI must be added to the view list last, as it must be on top
		}
		
		
		//**************************************************
		//
		//                INITIALIZATION
		//
		//**************************************************
		private function setupManagers(): void
		{
			//Resources
			//TODO: Properly detach events when switching states?  Or set to weak.
			ResourceManager.instance.addEventListener(ResourceEvent.RESOURCE_AMOUNTCHANGED, Resource_AmountChanged);
			_goldQuantity.text = ResourceManager.instance.getResource(ResourceManager.RESOURCETYPE_GOLD).toString();
			_ironQuantity.text = ResourceManager.instance.getResource(ResourceManager.RESOURCETYPE_IRON).toString();
			_silverQuantity.text = ResourceManager.instance.getResource(ResourceManager.RESOURCETYPE_SILVER).toString();
			
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
		private function setupGenericWorldData():void 
		{
			//TODO: Put Darkness into ActorManager
			//Darkness.Instance.enable();
			//Darkness.Instance.isStatic = true;
			//Darkness.Instance.addLight(Darkness.LIGHT_CIRCLE, 160, 200, 3);
			//Darkness.Instance.addLight(Darkness.LIGHT_CIRCLE_FLICKER, 180, 200);
			//Darkness.Instance.addLight(120, 200);
			//Darkness.Instance.addLight(150, 180);
			//Darkness.Instance.addLight(165, 170);
			//Darkness.Instance.addLight(170, 175);
			//Darkness.Instance.addLight(140, 160);
			//Darkness.Instance.addLight(120, 180);
		}
		private function setupUI():void
		{
			//Bottom "feedback" text
			_immediateFeedback = new FlxText(2, FlxG.height - 30, FlxG.width);
			_immediateFeedback.size = 16;
			
			
			//Resources texts
			_goldLabel = new FlxText(FlxG.width - 240, 0, 40, "Gold: ");
			_goldLabel.alignment = "right";
			_goldQuantity = new FlxText(FlxG.width - 200, 0, 40);
			
			_ironLabel = new FlxText(FlxG.width - 160, 0, 40, "Iron: ");
			_ironLabel.alignment = "right";
			_ironQuantity = new FlxText(FlxG.width - 120, 0, 40);
			
			_silverLabel = new FlxText(FlxG.width - 80, 0, 40, "Silver: ");
			_silverLabel.alignment = "right";
			_silverQuantity = new FlxText(FlxG.width - 40, 0, 40);
			
			
			//Resource buttons
			_goldPlusButton = new FlxButton(FlxG.width - 240, 20, "Add Gold", goldPlus_Click);
			_ironPlusButton = new FlxButton(FlxG.width - 160, 20, "Add Iron", ironPlus_Click);
			_silverPlusButton = new FlxButton(FlxG.width - 80, 20, "Add Silver", silverPlus_Click);
			
			
			//"New building" buttons
			var newQuartersContent:FlxButton = new FlxButton(FlxG.width - 160, 100, "New Quarters", newQuarters_Click);
			_newQuartersButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newQuartersContent, Building_Quarters, populateNewBuildingPopup);
			
			var newMageTowerContent:FlxButton = new FlxButton(FlxG.width - 160, 120, "New Mage Tower", newMageTower_Click);
			_newMageTowerButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newMageTowerContent, Building_MageTower, populateNewBuildingPopup);
			
			var newFenceContent:FlxButton = new FlxButton(FlxG.width - 160, 140, "New Fence", newFence_Click);
			_newFenceButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newFenceContent, Building_Fence, populateNewBuildingPopup);
			
			var newWallContent:FlxButton = new FlxButton(FlxG.width - 160, 160, "New Wall", newWall_Click);
			_newWallButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newWallContent, Building_Wall, populateNewBuildingPopup);
			
			var newCastleContent:FlxButton = new FlxButton(FlxG.width - 80, 100, "New Castle", newCastle_Click);
			_newCastleButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newCastleContent, Building_Castle, populateNewBuildingPopup);
			
			var newBarracksContent:FlxButton = new FlxButton(FlxG.width - 80, 120, "New Barracks", newBarracks_Click);
			_newBarracksButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newBarracksContent, Building_Barracks, populateNewBuildingPopup);
			
			var newFarmContent:FlxButton = new FlxButton(FlxG.width - 80, 140, "New Farm", newFarm_Click);
			_newFarmButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newFarmContent, Building_Farm, populateNewBuildingPopup);
			
			var newTrainingGroundsContent:FlxButton = new FlxButton(FlxG.width - 80, 160, "New Training", newTrainingGrounds_Click);
			_newTrainingGroundsButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newTrainingGroundsContent, Building_TrainingGrounds, populateNewBuildingPopup);
			
			var newBlacksmithContent:FlxButton = new FlxButton(FlxG.width - 80, 180, "New Smithy", newBlacksmith_Click);
			_newBlacksmithButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newBlacksmithContent, Building_Blacksmith, populateNewBuildingPopup);
			
			var newArmouryContent:FlxButton = new FlxButton(FlxG.width - 80, 200, "New Armoury", newArmoury_Click);
			_newArmouryButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newArmouryContent, Building_Armoury, populateNewBuildingPopup);
			
			var newBarberContent:FlxButton = new FlxButton(FlxG.width - 80, 220, "New Barber", newBarber_Click);
			_newBarberButton = new FlxObjectWithPopup(Pilot.POPUPIMG_PNG, newBarberContent, Building_Barber, populateNewBuildingPopup);
			
			_removeBuildingButton = new FlxButton(FlxG.width - 80, 260, "Remove Building", removeBuilding);
			
			//State buttons
			_mapButton = new FlxButton(FlxG.width - 80, FlxG.height - 20, "Quest Map", questMap_Click);
			
			
			if (QuestManager.questLibrary[QuestManager.QUEST_MINIONHOUSING1].state == Quest.QUESTSTATE_NONE)
			{
				QuestManager.instance.makeQuestAvailable(QuestManager.QUEST_MINIONHOUSING1);
				_tut = new FlxPopup(true, Pilot.POPUPIMG_PNG, "This is your territory and where you will build structures.  Your minions will carry out the construction of anything you desire, your first task is to get used to the building process.", "Welcome to Kingdom! ", 280, 210, 200, 160, 194, 247, 0x777777);
			}
		}
		
		private function finalizeUI():void
		{
			//Bottom "feedback" text
			add(_immediateFeedback);
			
			
			//Resources texts
			add(_goldLabel);
			add(_goldQuantity);
			
			add(_ironLabel);
			add(_ironQuantity);
			
			add(_silverLabel);
			add(_silverQuantity);
			
			
			//Resource buttons
			add(_goldPlusButton);
			add(_ironPlusButton);
			add(_silverPlusButton);
			
			
			//"New building" buttons
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
			
			
			//State buttons
			add(_mapButton);
			
			
			//"Welcome" popup
			add(_tut);
		}
		
		
		//**************************************************
		//
		//                BUTTON FUNCTIONS
		//
		//**************************************************
		private function populateNewBuildingPopup(popup:FlxPopup, userData:*):void
		{
			var ud:Class = Class(userData);
			popup.header = ud.name;
			popup.content = ud.resourceCost.getResource(ResourceManager.RESOURCETYPE_GOLD).toString() + " gold\n" +
							ud.resourceCost.getResource(ResourceManager.RESOURCETYPE_IRON).toString() + " iron\n" +
							ud.resourceCost.getResource(ResourceManager.RESOURCETYPE_SILVER).toString() + " silver\n\n" +
							ud.maxHealth.toString() + " health\n";
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
			_preBuildDisplay = new PreBuildDisplay(buildingCls);
			_preBuildDisplay.addEventListener(PreBuildDisplay.BUILDDISPLAY_OK, preBuildOk_Click);
			_preBuildDisplay.addEventListener(PreBuildDisplay.BUILDDISPLAY_CANCEL, preBuildCancel_Click);
			add(_preBuildDisplay);
			
			Cc.log("Created PreBuildDisplay for \"" + buildingCls.name + "\"");
		}
		private function removePreBuildDisplay():void
		{
			if (_preBuildDisplay)
			{
				remove(_preBuildDisplay);
				_preBuildDisplay.removeEventListener(PreBuildDisplay.BUILDDISPLAY_OK, preBuildOk_Click);
				_preBuildDisplay.removeEventListener(PreBuildDisplay.BUILDDISPLAY_CANCEL, preBuildCancel_Click);
				_preBuildDisplay.destroy();
				_preBuildDisplay = null;
			}
		}
		private function preBuildOk_Click(e:Event):void
		{
			var buildingCls:Class = _preBuildDisplay.buildingCls;
			_currentNewBuildingCost = buildingCls.resourceCost;
			if (ResourceManager.instance.checkResources(buildingCls.resourceCost))
			{
				_worldView.holdBuilding(_preBuildDisplay.building);
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
		
		private function goldPlus_Click():void 
		{
			ResourceManager.instance.addResource(ResourceManager.RESOURCETYPE_GOLD, 100);
		}
		private function ironPlus_Click():void 
		{
			ResourceManager.instance.addResource(ResourceManager.RESOURCETYPE_IRON, 100);
		}
		private function silverPlus_Click():void 
		{
			ResourceManager.instance.addResource(ResourceManager.RESOURCETYPE_SILVER, 100);
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
				case ResourceManager.RESOURCETYPE_GOLD:
					{
						_goldQuantity.text = e.newAmount.toString();
						break;
					}
				case ResourceManager.RESOURCETYPE_IRON:
					{
						_ironQuantity.text = e.newAmount.toString();
						break;
					}
				case ResourceManager.RESOURCETYPE_SILVER:
					{
						_silverQuantity.text = e.newAmount.toString();
						break;
					}
			}
		}
		
		
		public override function update():void
		{
			super.update();
		}
		public override function draw():void
		{
			super.draw();
		}
	}
}

