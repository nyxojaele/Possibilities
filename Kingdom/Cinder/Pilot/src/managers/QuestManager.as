package managers 
{
	import com.adobe.protocols.dict.DictionaryServer;
	import com.junkbyte.console.Cc;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import managers.city.CityEvent;
	import managers.minions.Minion;
	import managers.minions.MinionBuilder;
	import managers.minions.MinionBuilderCollection;
	import managers.minions.MinionStatCollection;
	import managers.quests.GametimeQuest;
	import managers.quests.Quest;
	import managers.quests.QuestEvent;
	import managers.quests.RealtimeQuest;
	import managers.quests.Reward;
	import managers.quests.StepQuest;
	import managers.resources.ResourceCollection;
	/**
	 * ...
	 * @author Jed Lang
	 */
	public class QuestManager extends Manager implements IUpdatingManager
	{
		//Singleton
		private static var _instance:QuestManager;
		public static function get instance():QuestManager
		{
			if (!_instance)
			{
				initQuestLibrary();	//We need these in place before Quest Classes can be determined
				_instance = new QuestManager();
			}
			return _instance;
		}
		
		
		//The following consts and the array after must match each other
		//Indices must start as 0, as they're also used to index into _questLibrary
		//Basic repeatable resource quests
		public static const QUEST_RESOURCEWOOD1:uint = 0;
		public static const QUEST_RESOURCEGOLD1:uint = 1;
		public static const QUEST_RESOURCEFOOD1:uint = 2;
		//Startup tutorial quests
		public static const QUEST_MINIONHOUSING1:uint = 3;
		public static const QUEST_ACQUIREMINION1:uint = 4;
		public static const QUEST_BARRACKS1:uint = 5;
		public static const QUEST_FARM1:uint = 6;
		//Forest quests
		public static const QUEST_FOREST1_1:uint = 7;
		public static const QUEST_FOREST1_2:uint = 8;
		public static const QUEST_FOREST2_1:uint = 9;
		public static const QUEST_FOREST2_2:uint = 10;
		public static const QUEST_FOREST2_3:uint = 11;
		public static const QUEST_FOREST3_1:uint = 12;
		public static const QUEST_FOREST3_2:uint = 13;
		//Desert quests
		public static const QUEST_DESERT1_1:uint = 14;
		public static const QUEST_DESERT1_2:uint = 15;
		public static const QUEST_DESERT1_3:uint = 16;
		public static const QUEST_DESERT2_1:uint = 17;
		public static const QUEST_DESERT2_2:uint = 18;
		public static const QUEST_DESERT2_3:uint = 19;
		public static const QUEST_DESERT3_1:uint = 20;
		public static const QUEST_DESERT3_2:uint = 21;
		//Village quests
		public static const QUEST_VILLAGE1_1:uint = 22;
		public static const QUEST_VILLAGE2_1:uint = 23;
		public static const QUEST_VILLAGE3_1:uint = 24;
		//Cave quests
		public static const QUEST_CAVE2_1:uint = 25;
		public static const QUEST_CAVE2_2:uint = 26;
		public static const QUEST_CAVE3_1:uint = 27;
		public static const QUEST_CAVE3_2:uint = 28;
		public static const QUEST_CAVE4_1:uint = 29;
		//Abyss quests
		public static const QUEST_ABYSS4_1:uint = 30;
		//Ocean City quests
		public static const QUEST_OCEANCITY3_1:uint = 31;
		public static const QUEST_OCEANCITY3_2:uint = 32;
		public static const QUEST_OCEANCITY4_1:uint = 33;
		//Empire quests
		public static const QUEST_EMPIRE3_1:uint = 34;
		public static const QUEST_EMPIRE3_2:uint = 35;
		
		public static var questLibrary:Dictionary;//Contains every quest. Period.
		private static var questClasses:Dictionary;
		private static function initQuestLibrary():void
		{
			//Populate quest library
			questLibrary = new Dictionary();
			//************************************************
			//
			//        BASIC REPEATABLE RESOURCE QUESTS
			//
			//************************************************
			questLibrary[QUEST_RESOURCEWOOD1] = new GametimeQuest( -1, QUEST_RESOURCEWOOD1, "Chop wood", true,
				"You need wood in order to build and do various other tasks. Send a minion out to chop down some trees.",
				"", -1, -1, 5, 0, null,
				new ResourceCollection(0, 1, 0), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_RESOURCEGOLD1] = new GametimeQuest( -1, QUEST_RESOURCEGOLD1, "Mine gold", true,
				"You need gold in order to build and do various other tasks. Send a minion out to mine some gold.",
				"", -1, -1, 5, 0, null,
				new ResourceCollection(1, 0, 0), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_RESOURCEFOOD1] = new GametimeQuest( -1, QUEST_RESOURCEFOOD1, "Hunt for food", true,
				"You need food in order to feed your minions while they build and do other tasks. Send a minion out to hunt for food.",
				"", -1, -1, 5, 0, null,
				new ResourceCollection(0, 0, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//            STARTUP TUTORIAL QUESTS
			//
			//************************************************
			questLibrary[QUEST_MINIONHOUSING1] = new StepQuest( -1, QUEST_MINIONHOUSING1, "Build Housing", false,
				"It's going to be important that your minions have a place to sleep. Have one of your minions construct a house.",
				"Congratulations!  What a beautiful building! Notice that your minion is now more experienced in construction and will continue to gain experience as he builds more. Now that you've finished this quest, a new one has been unlocked on the quest map.",
				-1, -1, 1, [QUEST_ACQUIREMINION1],
				null, null, new MinionStatCollection(0, 0, 0, 1), null);
			questLibrary[QUEST_ACQUIREMINION1] = new GametimeQuest( -1, QUEST_ACQUIREMINION1, "Obtain Another Minion", false,
				"Minions are obtained from the world without much difficulty, but you must be able to house them. Higher level minions will cost more to produce, but low tier minions can always be obtained.",
				"Now you have another minion to help you build your kingdom.",
				-1, -1, 30, 0, [QUEST_BARRACKS1],
				null, new MinionBuilderCollection([new MinionBuilder()]), null, MinionStatCollection.empty);
			questLibrary[QUEST_BARRACKS1] = new StepQuest( -1, QUEST_BARRACKS1, "Build Barracks", false,
				"You will need additional resources to construct a barracks. Once built, you will be able to provide additional training to your minions and make them more prepared for combat!",
				"",
				-1, -1, 1, [QUEST_FARM1],
				null, null, null, null);
			questLibrary[QUEST_FARM1] = new StepQuest( -1, QUEST_FARM1, "Build a Farm", false,
				"Constructing a farm allows you to produce a harvest that feeds your minions and can be used for trade. Once you have more the 2 minions, you will require regular harvesting of food to sustain your minions. Minions without food or lodging will refuse orders and may even abandon you!",
				"",
				-1, -1, 1, [QUEST_FOREST1_1],
				null, null, null, null);
			
			//************************************************
			//
			//                 FOREST QUESTS
			//
			//************************************************
			questLibrary[QUEST_FOREST1_1] = new GametimeQuest( -1, QUEST_FOREST1_1, "Find Building Materials", true,
				"Just as with your camp, you’ll need more resources to construct additional buildings. We’re surrounded by a lush forest, and it will provide much of what we need. I’ve been in the forest many times, and it will be safe as long as our minions stay near the camp. If they go too far in, they may find themselves in danger.",
				"The trees and resources of this area are abundant, and now you can begin harvesting! One of your minions can be tasked with regularly retrieving material and bringing it back to your base for use. Use caution though, as local creatures may be unhappy with removing their forest!",
				180, 20, 300, 0, [QUEST_FOREST1_2],
				new ResourceCollection(0, 4, 0), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_FOREST1_2] = new GametimeQuest( -1, QUEST_FOREST1_2, "Explore Ruins", false,
				"The ruins that lie to the west are once part of a proud kingdom. It’s origins are ancient, long before my time, but the culture is not far removed. I’m almost certain its origins are alien to this world, much like you or me. It’s long since been destroyed, but it would be fascinating to learn more of its history.",
				"This ruin was a great find, but it’s impossible to dig deeper into the city at this time. It appears blocked by a massive amount of rubble that has been magically reinforced. For whatever the reason is that it’s blocked, it was done intentionally.",
				180, 40, 600, 0, [QUEST_FOREST2_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_FOREST2_1] = new GametimeQuest( -1, QUEST_FOREST2_1, "Find Gems", false,
				"Not far from the ruins lies an excavation, long overgrown and shadowy. This pit was once a source for great raw treasures, but is now reclaimed by the forest",
				"",
				180, 60, 600, 0, [QUEST_FOREST2_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_FOREST2_2] = new GametimeQuest( -1, QUEST_FOREST2_2, "Explore Towering Trees", false,
				"As you progress towards the heart of the forest, the ground has become permanent night from the denseness of the towering trees. Navigating along the thick branches could yield incredible rare materials, but also dangerous attacks from flying creatures.",
				"",
				180, 80, 600, 0, [QUEST_FOREST2_3],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_FOREST2_3] = new GametimeQuest( -1, QUEST_FOREST2_3, "Remove Reacher (Boss)", false,
				"Deep in the forest lies the alpha wolf, the leader of the wolves that have been ambushing your minions and attacking your structures. This fearsome creature does not take kindly to intruders, but removing him might make journeys in the forest and harvesting a little safer.",
				"",
				180, 100, 600, 0, [QUEST_FOREST3_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_FOREST3_1] = new GametimeQuest( -1, QUEST_FOREST3_1, "Watcher of the Forest (Boss)", false,
				"Rumor has it that at the deepest, darkest part of the forest, a being exists that defends the heart of the forest. This Watcher is by all accounts peaceful, but it stands vigilant against any that dare exploit the delicate inner circle of the forest.",
				"",
				180, 120, 600, 0, [QUEST_DESERT1_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//                 DESERT QUESTS
			//
			//************************************************
			questLibrary[QUEST_DESERT1_1] = new GametimeQuest( -1, QUEST_DESERT1_1, "Explore Oasis", false,
				"On the edge of the great sands there was once a beautiful pool that brought plenty of animals to its edges. Now it serves only as a graveyard of the creatures the came and perished, finding no life saving water to keep them alive.",
				"",
				360, 100, 300, 0, [QUEST_DESERT1_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT1_2] = new GametimeQuest( -1, QUEST_DESERT1_2, "Locate Desert Tribe", false,
				"This tribe has suffered greatly from the Oasis drying up and now it exists only as a handful of desperate people.",
				"Long ago, the oasis was fed from an underground spring from a nearby rock outcropping. The aqueduct that allowed it to flow here has long since fallen and we’ve not the knowledge to repair it. Without the aqueduct, the desert consumes the water long before it can reach us.",
				360, 120, 300, 0, [QUEST_DESERT1_3],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT1_3] = new GametimeQuest( -1, QUEST_DESERT1_3, "Scavenge Trade Route", false,
				"Once an important trade route, this path is scattered with the remains of many caravans that didn’t make their destination. There may be valuables still remaining along the way to acquire!",
				"",
				360, 140, 600, 0, [QUEST_DESERT2_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT2_1] = new GametimeQuest( -1, QUEST_DESERT2_1, "Locate Ancient Aqueduct", false,
				"The basic structure can be seen stretching for miles, but it must be broken at some point, as no water flows down. Following the line will easily take you to the source of the problem, but that is far beyond the sight of the forest and dangers may exist that way.",
				"The aqueduct has collapsed near the base of the rocks from which it starts. Tunneling scorpions have made it so unstable that it has fallen over. The beasts will have to be removed before it could be repaired.",
				360, 160, 600, 0, [QUEST_DESERT2_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT2_2] = new GametimeQuest( -1, QUEST_DESERT2_2, "Remove Scorpion Nest", false,
				"A new nest can be seen near the edges of the desert, if this continues to grow it could pose danger to your town. Remove the creatures before they become a serious issue.",
				"",
				360, 180, 600, 0, [QUEST_DESERT2_3],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT2_3] = new GametimeQuest( -1, QUEST_DESERT2_3, "Explore Twisted Rocks", false,
				"A natural spring comes out of these rocks that have pushed up from the core of the world. Other rare natural treasures may also exist that have escaped the grasp of the world!",
				"",
				360, 200, 600, 0, [QUEST_DESERT3_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT3_1] = new GametimeQuest( -1, QUEST_DESERT3_1, "Repair Ancient Aqueduct", false,
				"In order to make the repairs you will have to route out the scorpion infestation and kill the queen. This will be a difficult task, but one that must be done.",
				"",
				360, 220, 900, 0, [QUEST_DESERT3_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_DESERT3_2] = new GametimeQuest( -1, QUEST_DESERT3_2, "Locate Ocean City", false,
				"Where the sand ends and the ocean begins you will find an incredible city. Filled with traders and smugglers, anything you could ever want is there. It is ruled by proud and controlling leader, who commands with authority and conquers all he desires. Take care in Ocean city, it can be a great ally or tremendous enemy.",
				"",
				360, 240, 900, 0, [QUEST_VILLAGE1_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//                 VILLAGE QUESTS
			//
			//************************************************
			questLibrary[QUEST_VILLAGE1_1] = new GametimeQuest( -1, QUEST_VILLAGE1_1, "Find Explorer", false,
				"You’re the adventurous type right?  Might I interest you in a favour?  It will be rewarded of course. Not long ago a minion of mine ventured into the forest to locate potential mines and she has not returned. Here is a copy of the map we use and which direction she was headed. I’m not sure it does much good to hope she’s still alive, but I must try.",
				"It must be a miracle! She had been gone so long I had little choice but to fear the worst. Blame me for allowing her foolish desire to explore get the best of me. But you know, she might fit in well with you and your group. Please, feel free to have her join you if you wish, I know with you she would be much happier.",
				540, 150, 600, 0, [QUEST_VILLAGE2_1],
				null, new MinionBuilderCollection([new MinionBuilder(1, 5, 1, 1)]), null, MinionStatCollection.empty);
			questLibrary[QUEST_VILLAGE2_1] = new GametimeQuest( -1, QUEST_VILLAGE2_1, "Secure Border", false,
				"You’ve proven a most reliable friend, and friends need to stick together more then ever. Lately my traders have been more frequently ambushed along the Desert road on route to trade with Ocean City. I need some muscle to look into these bandits and stop them if possible.",
				"The bandits were from Ocean City? This is very disturbing, but it makes sense. We’ve known that they wanted to expand for some time, and now they’ve set their sights on our village. I fear this will get worse before long. Thank you for your help, and here is your reward. Don’t let this fall from your mind, Ocean City may have their sights set on you as well.",
				540, 170, 600, 0, [QUEST_VILLAGE3_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_VILLAGE3_1] = new GametimeQuest( -1, QUEST_VILLAGE3_1, "Choosing Sides", false,
				"We’ve begun war with Ocean City, and we have little hope of beating them alone. But together we stand a chance. Unfortunately, I have little to offer you, and even if we beat Ocean City, their city will remain. We’ve no spoils to split. What I can offer is our support for whatever you need.",
				"",
				540, 190, 600, 0, [QUEST_CAVE2_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//                  CAVE QUESTS
			//
			//************************************************
			questLibrary[QUEST_CAVE2_1] = new GametimeQuest( -1, QUEST_CAVE2_1, "Enter Cave", false,
				"The fabled deep caves of XXX. These have been explored time and again, and every time they’ve been secured for mining, something emerges to reclaim it. Magical creatures are drawn to its depths. Now it holds the gaze of a tremendous troll that waits patiently at its entrance, letting none pass.",
				"",
				120, 400, 600, 0, [QUEST_CAVE2_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_CAVE2_2] = new GametimeQuest( -1, QUEST_CAVE2_2, "Mine Cave", false,
				"There is a tale of a precious and rare mineral that builds the most durable weapons. Forged from the heat and pressure of the world, forced through the rocks in veins of unbreakable volcanic stone. Flowing like a trickle from the darkest places, obtaining this material will undoubtably produce the best weapons imaginable.",
				"",
				120, 420, 900, 0, [QUEST_CAVE3_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_CAVE3_1] = new RealtimeQuest( -1, QUEST_CAVE3_1, "Reinforce Tunnel", false,
				"The caves go deeper then imagined, but it’s far too risky to proceed. The echo of crashing stones follows deep tremors that shake these caves. If you wish to go even deeper into the world, you will first have to reinforce the way. That will take minions strengthening the way and those protecting their work.",
				"",
				120, 440, 1800, [QUEST_CAVE3_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_CAVE3_2] = new GametimeQuest( -1, QUEST_CAVE4_1, "Gate of the Abyss", false,
				"Beyond the spanning tunnels of the cave appears a great chasm. It spans miles of openness, like an unbelievable canyon within the world, filled with towering rocks reaching towards the sky, hidden by miles of stone. Towards the center of the massive space stands a small light, bright but unable to light the space. Hovering along the walls, moving erratically, a shadow, darker then the black of the room moves. It is impossible to say what it is, it is likely something no one has survived encountering before.",
				"",
				120, 460, 900, 0, [QUEST_ABYSS4_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//                  ABYSS QUESTS
			//
			//************************************************
			questLibrary[QUEST_ABYSS4_1] = new GametimeQuest( -1, QUEST_ABYSS4_1, "Cross the Barrier", false,
				"There is no way to tell what is beyond the gate, the only thought you have is that what you slain in the cave was but a shadow of a true form.",
				"The world fades back and light streaks past you until you come to your senses. The strange world is a collection of broken masses of land, hovering in space. The red soil and dark sky is lit with a bright red sun, and breaking pieces of land fall continuously into an unknown void. The gate stand behind and to once side is a cage, holding a creature. It speaks, not surprised by the strangers, 'Leave now, there is no hope'. Before you can turn, the Abyss Dragon appears in it’s true form, black and spined, ready for destruction.",
				340, 320, 1200, 0, [QUEST_OCEANCITY3_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//               OCEAN CITY QUESTS
			//
			//************************************************
			questLibrary[QUEST_OCEANCITY3_1] = new GametimeQuest( -1, QUEST_OCEANCITY3_1, "The Captain's Quest", false,
				"Another adventurer I see, come here for the trade or are you looking for work? If you find yourself particularly courageous, there is a task a require an outsider to perform. There was a particularly valuable shipment that was intercepted to the South further along the coast. It is far from the city and I’ve not the authority to send our troops. If you would return this cargo, you shall be well rewarded.",
				"Exceptional work, without these supplies, we would have had delays for months. Here is your rewards. As you’ve proven rather capable and trustworthy I have one additional quest that I need someone to perform.",
				520, 370, 600, 0, [QUEST_OCEANCITY3_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_OCEANCITY3_2] = new GametimeQuest( -1, QUEST_OCEANCITY3_2, "Assassin's Quest", false,
				"This involves a band of rather dangerous assassins camping near the tree line. We know of this camp and have tried to remove this threat, but my troops were defeated. If you could remove them we would be in your debt.",
				"That was impressive! I’ve already received word that the assassins were destroyed. This will be a tremendous relief to our king to not have to worry about these assassins any longer. Feel free to keep whatever you found, and also have this shield, it has served me in many battles and will keep you and your men strong.",
				520, 390, 900, 0, [QUEST_OCEANCITY4_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_OCEANCITY4_1] = new GametimeQuest( -1, QUEST_OCEANCITY4_1, "Blood and Sand", false,
				"Captain: 'I’ve been requested to bring you before the king to discuss an urgent matter.Please follow me.'\nKing: 'It’s no secret we have ambitions for this region and ones that involve making the right allies. You’ve proven yourself capable of acting, now you must make the right decisions. We are going to war with Village to secure the inland trade routes. We have little ambition beyond our trade, and we’re willing to give control of the region up to the trade route to you and your kingdom. Remove Village and it’s inhabitants and the spoils of victory are yours.  I expect your decision soon.'",
				"",
				520, 410, 600, 0, [QUEST_EMPIRE3_1],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			
			//************************************************
			//
			//                 EMPIRE QUESTS
			//
			//************************************************
			questLibrary[QUEST_EMPIRE3_1] = new GametimeQuest( -1, QUEST_EMPIRE3_1, "Damn the River", false,
				"Removing the water supply is the first step in bringing down the village. Use your engineers to dam the water, and protect them from any Village attacks.",
				"",
				700, 300, 600, 0, [QUEST_EMPIRE3_2],
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
			questLibrary[QUEST_EMPIRE3_2] = new GametimeQuest( -1, QUEST_EMPIRE3_2, "Burn the Food", false,
				"The second step is starving them out. Destroy the surrounding farms.",
				"",
				700, 320, 600, 0, null,
				new ResourceCollection(1, 1, 1), null, null, MinionStatCollection.empty);
		}
		
		//These next 2 functions must remain in sync!
		private static function getQuestClassById(id:uint):Class
		{
			switch (id)
			{
				case RealtimeQuest.questTypeString:
					return RealtimeQuest;
				case GametimeQuest.questTypeString:
					return GametimeQuest;
				case StepQuest.questTypeString:
					return StepQuest;
			}
			return null;
		}
		//This and the previous function must remain in sync!
		private static function getQuestIdByClass(cls:Class):int
		{
			if (cls == RealtimeQuest)
				return RealtimeQuest.questTypeString;
			else if (cls == GametimeQuest)
				return GametimeQuest.questTypeString;
			else if (cls == StepQuest)
				return StepQuest.questTypeString;
				
			return -1;
		}
		
		
		private var _questsAvailable:Array;			//Contains only the quest ids that are available to be, but not yet, started.
		private var _questsToUpdate:Array;			//Contains only the quest ids that have been started but not finished yet.
		private var _questsComplete:Array;			//Contains only the quest ids that have completed
		
		
		public function QuestManager() 
		{
			super("quests.php", requestReturn);
			
			_questsAvailable = [];
			_questsToUpdate = [];
			_questsComplete = [];
		}
		
		
		//**********************************************************************
		//
		//                            SERVER DATA
		//
		//**********************************************************************
		protected override function getMemberClassByTypeId(typeId:uint):Class
		{
			return QuestManager.getQuestClassById(typeId);
		}
		protected override function hydrateMemberWithServerData(member:ManagedItem, properties:Array):Boolean
		{
			if (properties.length < 4 ||
				isNaN(Number(properties[2])) ||
				!(member is Quest))
				return false;
			
			var questId:Number = Number(properties[2]);
			var state:uint = Number(properties[3]);
			var workingQuest:Quest = member as Quest;
			var actualQuest:Quest = questLibrary[questId];
			
			actualQuest.setID(workingQuest.id);					//Pass on the id
			if (!actualQuest.initFromServerData(properties))	//Initialize quest
				return false;
			initQuestState(questId, actualQuest, state);		//This will fire an event for any listeners of QUEST_BECAMEAVAILABLE, QUEST_STARTED, or QUEST_COMPLETED
			return true;
		}
		
		
		private function initQuestState(questId:uint, quest:Quest, state:uint):void
		{
			quest.setState(state);
			switch (state)
			{
				case Quest.QUESTSTATE_NONE: //This shouldn't be getting retrieved from the server!
					{
						Cc.warn("Retrieved quest \"" + quest.name + "\" from server with state 0");
						break;
					}
				case Quest.QUESTSTATE_AVAILABLE:
					{
						_questsAvailable.push(questId);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_BECAMEAVAILABLE, quest, questId));
						break;
					}
				case Quest.QUESTSTATE_STARTED:
					{
						_questsToUpdate.push(questId);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_STARTED, quest, questId));
						break;
					}
				case Quest.QUESTSTATE_FINISHED:
					{
						_questsComplete.push(questId);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_COMPLETE, quest, questId));
						break;
					}
			}
		}
		
		private function sendQuestAvailableRequest(quest:Quest):void
		{
			quest.setID(-Manager.requestID);	//Done before makeRequest so we get the value before it's incremented.
			//This should always be the first thing done for a quest in the DB,
			//so this is how it gets instantiated.
			var request:URLVariables = makeRequest("available");
			if (request)
			{
				request.type = QuestManager.getQuestIdByClass(Object(quest).constructor);
				request.questIndex = quest.questId;
				quest.populateAvailableRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestStartedEvent(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("start");
			if (request)
			{
				request.id = quest.id;
				quest.populateStartRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestUpdateRequest(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("update");
			if (request)
			{
				request.id = quest.id;
				quest.populateUpdateRequest(request);
				sendRequest(request);
			}
		}
		private function sendQuestFinishedEvent(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("finish");
			if (request)
			{
				request.id = quest.id;
				quest.populateFinishRequest(request);
				sendRequest(request);
			}
		}
		private function sendRepeatableQuestFinishedEvent(quest:Quest):void
		{
			//The quest rows should always be instantiated at this point, so we only need to modify it in the DB.
			var request:URLVariables = makeRequest("finishrepeatable");
			if (request)
			{
				request.id = quest.id;
				sendRequest(request);
			}
		}
		private function sendQuestResetRequest(quest:Quest):void
		{
			//The quest rows may or may not exist already, but we are deleting, so it doesn't much matter.
			var request:URLVariables = makeRequest("reset");
			if (request)
			{
				request.id = quest.id;
				sendRequest(request);
			}
		}
		private function requestReturn(e:ManagerEvent):void
		{
			var vars:URLVariables = new URLVariables(e.data);
			if (vars.Action == "available")
			{
				//Find quest by ID
				for each (var quest:Quest in questLibrary)
				{
					if (quest.id == -vars.RequestID)
					{
						dispatchEvent(new ManagerEvent(ManagerEvent.MANAGER_ITEMIDUPDATED, quest.id + ":" + vars.NewID));	//Special encoding of 2 values
						quest.setID(vars.NewID);
						break;
					}
				}
			}
		}
		
		
		//**********************************************************************
		//
		//                         NORMAL FUNCTIONS
		//
		//**********************************************************************
		public function makeQuestAvailable(questId:uint, sendRequest:Boolean=true):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questId in Quest Library: " + questId);
				return;
			}
			var quest:Quest = questLibrary[questId];
			if (quest.state != Quest.QUESTSTATE_NONE)
			{
				Cc.warn("Quest " + quest.id + " \"" + quest.name + "\" already available, started, or finished");
				return;
			}
				
			_questsAvailable.push(questId);
			
			quest.setState(Quest.QUESTSTATE_AVAILABLE);
			dispatchEvent(new QuestEvent(QuestEvent.QUEST_BECAMEAVAILABLE, quest, questId));
			sendQuestAvailableRequest(quest);
			Cc.info("Quest " + quest.id + " \"" + quest.name + "\" available");
		}
		public function startQuest(questId:uint):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questId in Quest Library: " + questId);
				return;
			}
			var quest:Quest = questLibrary[questId];
			if (quest.state != Quest.QUESTSTATE_AVAILABLE)
			{
				Cc.warn("Quest " + quest.id + " \"" + quest.name + "\" already started");
				return;
			}
			
			_questsAvailable.splice(_questsAvailable.indexOf(questId), 1);
			_questsToUpdate.push(questId);
			
			quest.setState(Quest.QUESTSTATE_STARTED);
			quest.start();
			dispatchEvent(new QuestEvent(QuestEvent.QUEST_STARTED, quest, questId));
			sendQuestStartedEvent(quest);
			Cc.info("Quest " + quest.id + " \"" + quest.name + "\" started");
		}
		public function updateQuest(questId:uint, value:*=null):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questId in Quest Library: " + questId);
				return;
			}
			var quest:Quest = questLibrary[questId];
			if (!quest.state == Quest.QUESTSTATE_STARTED)
			{
				Cc.warn("Quest " + quest.id + " \"" + quest.name + "\" can not be updated");
				return;
			}
			
			quest.updateValue(value);
			sendQuestUpdateRequest(quest);
		}
		public function resetQuest(questId:uint):void
		{
			if (questLibrary[questId] == undefined)
			{
				Cc.error("Undefined questid in Quest Library: " + questId);
				return;
			}
			
			//Quest values
			var quest:Quest = questLibrary[questId];
			quest.setState(Quest.QUESTSTATE_NONE);
			quest.setShouldUpdateServer(false);
			quest.reset();
			
			//Remove from arrays
			var idx:Number = _questsAvailable.indexOf(questId);
			if (idx != -1)
				_questsAvailable.splice(idx, 1);
			idx = _questsToUpdate.indexOf(questId);
			if (idx != -1)
				_questsToUpdate.splice(idx, 1);
			idx = _questsComplete.indexOf(questId);
			if (idx != -1)
				_questsComplete.splice(idx, 1);
			
			//Server
			sendQuestResetRequest(quest);
		}
		
		
		public function update():void
		{
			var removeQuests:Array = [];
			var questsToStart:Array = [];
			//Update quests
			for each (var questId:uint in _questsToUpdate)
			{
				var quest:Quest = questLibrary[questId];
				var questComplete:Boolean = quest.update();
				//After an update, but before "finishing" a quest, we may need to update the server on the quest's progress
				if (quest.shouldUpdateServer)
				{
					sendQuestUpdateRequest(quest);
					quest.setShouldUpdateServer(false);
				}
				//Now we can finish the quest if required
				if (questComplete)
				{
					//Assign rewards first as some rely on checking stuff that's set for the quest
					for each (var reward:Reward in quest.rewards)
						reward.apply(questId);
					
					//Unlock quests
					for each (var currentQuestId:Number in quest.unlocksQuestIds)
					{
						makeQuestAvailable(currentQuestId);	//Safe because it updates _questsAvailable only
						if ((QuestManager.questLibrary[currentQuestId] as Quest).requiredStats == null)
							//Doesn't need a minion to "go on the quest"
							questsToStart.push(currentQuestId);
					}
						
					removeQuests.push(questId);
					
					if (quest.repeatable)
					{
						//If it's repeatable, make it available again
						Cc.info("Repeatable Quest " + quest.id + " \"" + quest.name + "\" complete");
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_COMPLETE, quest, questId));
						quest.setState(Quest.QUESTSTATE_AVAILABLE);
						quest.reset();
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_BECAMEAVAILABLE, quest, questId));
						sendRepeatableQuestFinishedEvent(quest);
					}
					else
					{
						//Otherwise, put it in the complete array
						Cc.info("Quest " + quest.id + " \"" + quest.name + "\" complete");
						quest.setState(Quest.QUESTSTATE_FINISHED);
						dispatchEvent(new QuestEvent(QuestEvent.QUEST_COMPLETE, quest, questId));
						sendQuestFinishedEvent(quest);
						_questsComplete.push(questId);
					}
				}
				else if (quest.updatePending)
					//If we didn't finish the quest before, maybe the quest has a value update to share
					dispatchEvent(new QuestEvent(QuestEvent.QUEST_UPDATED, quest, questId));
			}
			//Cleanup completed quests
			for each (var removeQuestId:uint in removeQuests)
			{
				_questsToUpdate.splice(_questsToUpdate.indexOf(removeQuestId), 1);
			}
			//Start new quests that are required
			for each (var startQuestId:uint in questsToStart)
			{
				startQuest(startQuestId);
			}
		}
	}

}