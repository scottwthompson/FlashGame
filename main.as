package 
{
	import fl.containers.ScrollPane;
	import fl.controls.TextArea;
	import fl.events.InteractionInputType;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author yo mama
	 */
	public class main extends MovieClip
	{
		private var menuStart:mcStartGameScreen;
		private var menuLevelSelect:mcLevelSelectScreen;
		private var menuSettings:mcSettingsScreen;
		private var menuBreifing:mcBreifingScreen;
		private var menuFeedback:mcFeedbackScreen;
		
		public var mcFinishBtn:MovieClip;
		public var mcSettingsBtn:MovieClip;
		public var mcBreifingBtn:MovieClip;
		public var mcLevelSelectBtn:MovieClip;
		
		public var mcFirewallText:TextArea;
		
		public var mcTerminalPane:MovieClip;
		public var origPane:MovieClip;
		private var scrollPane:ScrollPane = null;
				
		private var newLine = new TextField();
		private var currentTerminalY = 5;
		private var chains:Dictionary = new Dictionary();
		private var chainPolicy:Dictionary = new Dictionary();
		
		private var currLevel:int = 0;
		private var currDifficulty:int = 0;
		private var answers:Array = new Array();
		private var levels:Array = new Array();
		
		public function main() {
			
			mcFinishBtn.buttonMode = true;
			mcFinishBtn.addEventListener(MouseEvent.CLICK, finishLevel);
			
			mcBreifingBtn.buttonMode = true;
			mcBreifingBtn.addEventListener(MouseEvent.CLICK, giveBreifing);
			
			mcLevelSelectBtn.buttonMode = true;
			mcLevelSelectBtn.addEventListener(MouseEvent.CLICK, selectLevel);
			
			mcSettingsBtn.buttonMode = true;
			mcSettingsBtn.addEventListener(MouseEvent.CLICK, openSettings);
			mcFirewallText.editable = false;
			
			startScenes();
			setupLevels();
			terminalSetup();
		}
		
		private function selectLevel(e:MouseEvent):void 
		{
			menuLevelSelect.showsScreen();
		}
		
		private function giveBreifing(e:MouseEvent):void 
		{
			menuBreifing.showsScreen();
		}
		
		public function terminalSetup():void 
		{
			mcTerminalPane.opaqueBackground = 0x000000;
			newTerminalLine();
		}
		
		public function startScenes() {
			var startLoader:Loader = new Loader();
			startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, startFeedback);
			startLoader.load(new URLRequest("feedback.swf"));
			
			var startLoader:Loader = new Loader();
			startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, startBreifing);
			startLoader.load(new URLRequest("breifing.swf"));
			
			var startLoader:Loader = new Loader();
			startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, startLevelSelect);
			startLoader.load(new URLRequest("levelSelect.swf"));
			
			var startLoader:Loader = new Loader();
			startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, startSettings);
			startLoader.load(new URLRequest("settings.swf"));
			
			var startLoader:Loader = new Loader();
			startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, startMenuScreen);
			startLoader.load(new URLRequest("startScreen.swf"));
					
		}
		
				
		private function startMenuScreen(e:Event):void 
		{
			menuStart = e.target.content as mcStartGameScreen;
			menuStart.addEventListener("START_GAME", playGame);
			addChild(menuStart);
		}
				
		private function startSettings(e:Event):void 
		{
			menuSettings = e.target.content as mcSettingsScreen;
			menuSettings.addEventListener("DIFF_UPDATE", difficultChange);
			addChildAt(menuSettings,numChildren);
			menuSettings.hideScreen();
		}
		
		private function startFeedback(e:Event):void 
		{
			menuFeedback = e.target.content as mcFeedbackScreen;
			menuFeedback.addEventListener("OPEN_SETTINGS", openSettings);
			menuFeedback.addEventListener("SELECT_LEVEL", feedTolvlSelect);
			menuFeedback.addEventListener("RESTART_LEVEL", restartLevel);
			menuFeedback.addEventListener("NEXT_LEVEL", nextLevel);
			addChild(menuFeedback);
			menuFeedback.hideScreen();
		}
		
		private function startBreifing(e:Event):void {
			menuBreifing = e.target.content as mcBreifingScreen;
			menuBreifing.addEventListener("SELECT_LEVEL", breifToLvlSlct);
			menuBreifing.addEventListener("OPEN_SETTINGS", openSettings);
			addChild(menuBreifing);
			menuBreifing.hideScreen();
		}
						
		private function startLevelSelect(e:Event):void  {
			menuLevelSelect = e.target.content as mcLevelSelectScreen;
			menuLevelSelect.addEventListener("START_LEVEL", levelSelected);
			menuLevelSelect.addEventListener("OPEN_SETTINGS", openSettings);
			menuLevelSelect.addEventListener("BACK_HOME", backHome);
			addChildAt(menuLevelSelect,numChildren-2);
			menuLevelSelect.hideScreen();
		}
		
		private function levelSelected(e:Event):void 
		{
			currLevel = menuLevelSelect.currLevel;
			menuLevelSelect.visible = false;
			
			var brief:String = "";
			if (currDifficulty == 0) {
				brief = levels[currLevel].briefing_easy;
			} else if (currDifficulty == 1) {
				brief = levels[currLevel].briefing_medium;
			} else {
				brief = levels[currLevel].briefing_hard;
			}
			
			menuBreifing.update(brief);
			menuBreifing.visible = true;
			setupChains(levels[currLevel]);
			hardResetTerminal();
		}
		
		private function setupChains(level:Object):void {
			if (level.chains && level.chainsPolicy) {
				chains = new Dictionary();
				chains["INPUT"] = new Array();
				chains["FORWARD"] = new Array();
				chains["OUTPUT"] = new Array();
				chains["ALL"] = new Array();
				for (var chain:String in level.chains) {
					if (chain != "ALL") {
						for (var rule:String in level.chains[chain]) {
							chains[chain].push(level.chains[chain][rule].clone())
						}
					}
				}
				chainPolicy = clone(level.chainsPolicy)
			} else {
				chains = new Dictionary();
				chainPolicy = new Dictionary();
				chains["INPUT"] = new Array();
				chainPolicy["INPUT"] = "ACCEPT";
				chains["FORWARD"] = new Array();
				chainPolicy["FORWARD"] = "ACCEPT";
				chains["OUTPUT"] = new Array();
				chainPolicy["OUTPUT"] = "ACCEPT";
				chains["ALL"] = new Array();
			}
		}
		private function difficultChange(e:Event):void {
			currDifficulty = menuSettings.difficulty;
			var brief:String = "";
			if (currDifficulty == 0) {
				brief = levels[currLevel].briefing_easy;
			} else if (currDifficulty == 1) {
				brief = levels[currLevel].briefing_medium;
			} else {
				brief = levels[currLevel].briefing_hard;
			}
			
			menuBreifing.update(brief);
			menuSettings.visible = false;
		}
		private function breifToLvlSlct(e:Event):void 
		{
			menuBreifing.hideScreen();
			menuLevelSelect.showsScreen();
		}
		
		private function backHome(e:Event):void 
		{

			menuLevelSelect.hideScreen();
			menuStart.showsScreen();
		}
		
		private function nextLevel(e:Event):void 
		{
			if (levels[currLevel + 1]) {
				currLevel++;
				setupChains(levels[currLevel]);
				menuFeedback.hideScreen();
				var brief:String = "";
				if (currDifficulty == 0) {
					brief = levels[currLevel].briefing_easy;
				} else if (currDifficulty == 1) {
					brief = levels[currLevel].briefing_medium;
				} else {
					brief = levels[currLevel].briefing_hard;
				}

				menuBreifing.update(brief);
				menuBreifing.showsScreen();
				hardResetTerminal();
			} else {
				menuFeedback.hideScreen();
				menuLevelSelect.showsScreen();
			}
		}
		
		private function restartLevel(e:Event):void 
		{
			menuFeedback.hideScreen();
			setupChains(levels[currLevel]);
			hardResetTerminal();
		}
		
		private function feedTolvlSelect(e:Event):void 
		{
			menuFeedback.hideScreen();
			menuLevelSelect.showsScreen();
		}
		
		private function openSettings(e:Event):void 
		{
			menuSettings.visible = true;
		}
		
		private function newTerminalLine():void 
		{
			if (currentTerminalY > 315) {
				mcTerminalPane.height = mcTerminalPane.height + 20;
				mcTerminalPane.scaleX = 1.0
				mcTerminalPane.scaleY = 1.0
				
				var termPreSym = new TextField();
				mcTerminalPane.addChild(termPreSym);
				termPreSym.width = 20;
				termPreSym.height = 20;
				termPreSym.x = 5;
				termPreSym.y = currentTerminalY;
				termPreSym.border = false
				termPreSym.type = TextFieldType.DYNAMIC;
				termPreSym.text = ">";
				termPreSym.textColor = 0xFFFFFF;

				newLine = new TextField();
				mcTerminalPane.addChild(newLine);
				newLine.width = 450;
				newLine.height = 20;
				newLine.x = 25;
				newLine.y = currentTerminalY;
				newLine.border = false
				newLine.type = TextFieldType.INPUT;
				newLine.textColor = 0xFFFFFF;
				newLine.addEventListener(KeyboardEvent.KEY_UP, terminalKeyHandler);

				currentTerminalY = currentTerminalY + 20;
				if (scrollPane) {
					removeChild(scrollPane);
				}
				scrollPane = new ScrollPane();
				scrollPane.x = 25.85;
				scrollPane.y = 263.6;
				scrollPane.width = 503;
				scrollPane.height = 315;
				scrollPane.visible = true;
				scrollPane.source = mcTerminalPane;
				addChildAt(scrollPane,7);
				stage.focus = newLine;
			} else {
				if (scrollPane) {
					removeChild(scrollPane);
				}
				scrollPane = new ScrollPane();
				scrollPane.x = 25.85;
				scrollPane.y = 263.6;
				scrollPane.width = 503;
				scrollPane.height = 315;
				scrollPane.visible = true;
				scrollPane.source = mcTerminalPane;
				addChildAt(scrollPane,7);
				stage.focus = newLine;
				
				var termPreSym = new TextField();
				mcTerminalPane.addChild(termPreSym);
				termPreSym.width = 20;
				termPreSym.height = 20;
				termPreSym.x = 5;
				termPreSym.y = currentTerminalY;
				termPreSym.border = false
				termPreSym.type = TextFieldType.DYNAMIC;
				termPreSym.text = ">";
				termPreSym.textColor = 0xFFFFFF;

				newLine = new TextField();
				mcTerminalPane.addChild(newLine);
				newLine.width = 450;
				newLine.height = 20;
				newLine.x = 25;
				newLine.y = currentTerminalY;
				newLine.border = false
				newLine.type = TextFieldType.INPUT;
				newLine.textColor = 0xFFFFFF;
				newLine.addEventListener(KeyboardEvent.KEY_UP, terminalKeyHandler);

				currentTerminalY = currentTerminalY + 20;
				stage.focus = newLine;
			}
		}
		
		private function terminalKeyHandler(e:KeyboardEvent):void 
		{
			if (e.keyCode == 13) {
				newLine.type = TextFieldType.DYNAMIC;
				newTerminalResponse(newLine.text);
				newTerminalLine();
				if (scrollPane) {
					scrollPane.verticalScrollPosition = int.MAX_VALUE;
				}
			}
		}
		
		public function hardResetTerminal():void 
		{
			updateFWText();
			while (mcTerminalPane.numChildren > 3) {
				mcTerminalPane.removeChildAt(3)
			}
			if (scrollPane) {
				//removeChild(scrollPane);
			}
			currentTerminalY = 5;
			terminalSetup();
		}
		
		private function showScreen():void 
		{
			this.visible = true;
		}
		
		private function hideScreen():void 
		{
			this.visible = false;
		}
		
		private function newTerminalResponse(object:Object):void 
		{
				var response:String = "";
			
				var pattern:RegExp = /(\S+)/g;
				var input:String = object as String
				var regResult:Array = [];
				var result:Object = null;
				while (result = pattern.exec(input)) {
					regResult.push(result[0]);
				}
				
				var sudo:Boolean = false;
				var iptables:Boolean = false;
				var help = false;
				
				var badArg:String = "";
				
				//Commands
				var L:String = "";
				var A:String = "";
				
				var I:String = "";
				var Inum:int = 1;
				var D:String = "";
				var Dnum:int = 1;
				var R:String = "";
				var Rnum:int = -1;
				var Eold:String = "";
				var Enew:String = "";
				var Pchain:String = "";
				var Pol:String = "";
				var F:String = "";
				
				//Options
				
				var m:String = "";
				var p:String = "";
				var dport:String = "";
				var sport:String = "";
				var j:String = "";	
				var i:String = "";
				var v:Boolean = false;
				var s:String = "";	
				var d:String = "";
				var o:String = "";
				var ctstate:String = "";
				
				for (var x = 0; x < regResult.length; x = x + 1) {
					if (x == 0 && regResult[0] == "sudo" && regResult[1] == "iptables") {
						sudo = true;
						iptables = true;
						x++;
					} else if (x == 0 && regResult[x] == "iptables") {
						iptables = true;
					} else if (regResult[x] == "-L" || regResult[x] == "--list") {
						if (regResult[x + 1]) {
							L = regResult[x + 1];
							x++;
						} else {
							L = "ALL";
						}
					} else if (regResult[x] == "-h" || regResult[x] == "--help") {
						help = true;
					} else if (regResult[x] == "-A" || regResult[x] == "--append") {
						if (regResult[x + 1]) {
							A = regResult[x + 1];
							x++; 
						} else {
							A = "NONE";
						}
					} else if (regResult[x] == "-m" || regResult[x] == "--match") {
						if (regResult[x + 1]) {
							m = regResult[x + 1];
							x++; 
						} else {
							m = "NONE";
						}
					} else if (regResult[x] == "--ctstate") {
						if (regResult[x + 1]) {
							ctstate = regResult[x + 1];
							x++; 
						} else {
							ctstate = "NONE";
						}
					} else if (regResult[x] == "-p" || regResult[x] == "--proto") {
						if (regResult[x + 1]) {
							p = regResult[x + 1];
							x++; 
						} else {
							p = "NONE";
						}
					} else if (regResult[x] == "--dport") {
						if (regResult[x + 1]) {
							dport = regResult[x + 1];
							x++; 
						} else {
							dport = "NONE";
						}
					} else if (regResult[x] == "--sport") {
						if (regResult[x + 1]) {
							sport = regResult[x + 1];
							x++; 
						} else {
							sport = "NONE";
						}
					} else if (regResult[x] == "-j" || regResult[x] == "--jump") {
						if (regResult[x + 1]) {
							j = regResult[x + 1];
							x++; 
						} else {
							j = "NONE";
						}
					} else if (regResult[x] == "-i" || regResult[x] == "--in-interface") {
						if (regResult[x + 1]) {
							i = regResult[x + 1];
							x++; 
						} else {
							i = "NONE";
						}
					} else if (regResult[x] == "-I" || regResult[x] == "--insert") {
						if (regResult[x + 1] && regResult[x+2] && !(isNaN(Number(regResult[x+2])))) {
							I = regResult[x + 1];
							Inum = Number(regResult[x +2]);
							x = x + 2; 
						} else if (regResult[x + 1]) {
							I = regResult[x + 1];
							x = x + 1;
						} else {
							I = "NONE";
						}
					} else if (regResult[x] == "-D" || regResult[x] == "--delete") {
						if (regResult[x + 1] && regResult[x+2] && !(isNaN(Number(regResult[x+2])))) {
							D = regResult[x + 1];
							Dnum = Number(regResult[x +2]);
							x = x + 2; 
						} else if (regResult[x + 1]) {
							D = regResult[x + 1];
							x = x + 1;
						} else {
							D = "NONE";
						}
					} else if (regResult[x] == "-R" || regResult[x] == "--replace") {
						if (regResult[x + 1] && regResult[x+2] && !(isNaN(Number(regResult[x+2])))) {
							R = regResult[x + 1];
							Rnum = Number(regResult[x +2]);
							x = x + 2; 
						} else if (regResult[x + 1]) {
							R = regResult[x + 1];
							Rnum = 1
							x = x + 1;
						} else {
							R = "NONE";
						}
					} else if (regResult[x] == "-v" || regResult[x] == "--verbose") {
						v = true;
					} else if (regResult[x] == "-s" || regResult[x] == "--source") {
						if (regResult[x + 1]) {
							s = regResult[x + 1];
							x++; 
						} else {
							s = "NONE";
						}
					} else if (regResult[x] == "-d" || regResult[x] == "--destination") {
						if (regResult[x + 1]) {
							d = regResult[x + 1];
							x++; 
						} else {
							d = "NONE";
						}
					} else if (regResult[x] == "-o" || regResult[x] == "--out-interface") {
						if (regResult[x + 1]) {
							o = regResult[x + 1];
							x++; 
						} else {
							o = "NONE";
						}
					} else if (regResult[x] == "-F" || regResult[x] == "--flush") {
						if (regResult[x + 1]) {
							F = regResult[x + 1];
							x++; 
						} else {
							F = "ALL";
						}
					} else if (regResult[x] == "-P" || regResult[x] == "--policy") {
						if (regResult[x + 1] && regResult[x + 2] && chains[regResult[x+1]] != null && (regResult[x+2] == "DROP" || regResult[x+2] == "ACCEPT")) {
							Pchain = regResult[x + 1] 
							Pol = regResult[x + 2];
							x = x + 2;
						} else if (regResult[x + 1] && regResult[x + 2] && chains[regResult[x+1]] != null) {
							Pchain = "BAD";
						} else if (!(regResult[x + 1] && regResult[x + 2])) {
							Pchain = "REQUIRES";
							if (regResult[x + 1]) {
								x = x +1;
							}
						} else {
							Pchain = "NONE";
							x = x + 2;
						}
					} else if (regResult[x] == "--rename-chain" || regResult[x] == "-E") {
						if (regResult[x + 1] && regResult[x + 2] && chains[regResult[x+1]] != null && (regResult[x+1] != "INPUT" || regResult[x+1] != "FORWARD" || regResult[x+1] != "OUTPUT")) {
							Eold = regResult[x + 1];
							Enew = regResult[x + 2];
							x = x + 2;
						} else if (regResult[x + 1] && regResult[x + 2] && (regResult[x+1] == "INPUT" || regResult[x+1] == "FORWARD" || regResult[x+1] == "OUTPUT")) {
							Eold = "PROHIBITED";
							x = x + 2;
						} else if (!(regResult[x + 1] && regResult[x + 2])) {
							Eold = "REQUIRES";
							if (regResult[x + 1]) {
								x = x +1;
							}
						} else {
							Eold = "NONE";
							x = x +2;
						}
					} else {
						if (!badArg && iptables) {
							badArg = regResult[x];
						} else if (!iptables) {
							response = regResult[0] + ": command not found";
						}
					}
				}
				var cmds:Array = [L, A, I, D, R, Eold, Pchain, F];
				var cmdstr:Array = ["-L", "-A", "-I", "-D", "-R", "-E", "-P", "-F"];
				
				
				if (iptables) {
					var cmd1 = "";
					var cmd2 = "";
					for (var cmd:String in cmds) {
						if (cmds[cmd] && !cmd1) {
							cmd1 = cmdstr[cmds.indexOf(cmds[cmd])];
						} else if (cmds[cmd] && cmd1 && !cmd2) {
							cmd2 = cmdstr[cmds.indexOf(cmds[cmd])];
						}
					}
					if (cmd1 && !cmd2) {
						//One command given
						if (badArg) {
							response = "Bad argument '" + badArg +"'\nTry 'iptables -h' or 'iptables --help' for more information";
						} else if (!sudo) {
							response = "iptables v1.4.21: can't initialize iptables table `filter': Permission denied (you must be root)\nPerhaps iptables or your kernel needs to be upgraded."
						} else {
							
							if (L) {
								if (chains[L] != null) {
									response += "\n";
									if (L == "ALL") {
										for (var chain:String in chains) {
											if (chain != "ALL") {
												response += "Chain " + chain +  " (policy "+chainPolicy[chain]+")\ntarget          prot opt source				           destination\n";
												for (var rule:String in chains[chain]) {
													response += chains[chain][rule].toRuleString();
												}
											}
											response += "\n";
										}
									} else {
										response += "Chain " + L +  " (policy "+chainPolicy[L]+")\ntarget          prot opt source				           destination\n";
										for (var rule:String in chains[L]) {
											response += chains[L][rule].toRuleString();
										}
									}
								} else {
									response = "iptables: No chain/target/match by that name";
								}
							} else if (A) {
								var obj = createRule(m, p, dport, sport, j, i, v, s, d, o, ctstate,A);
								var errBool = obj.error;
								var rulen:Rule = obj.rule;
								if (!errBool) {
									if (chains[A] != null) {
										chains[A].push(rulen);
									} else {
										response = "iptables: No chain/target/match by that name";
									}
								} else {
									response = errBool;
								}
							} else if (I) {
								var obj = createRule(m, p, dport, sport, j, i, v, s, d, o, ctstate,I);
								var errBool = obj.error;
								var rulen:Rule = obj.rule;
								if (!errBool) {
									if (chains[I] != null) {
										if (Inum <= chains[I].length) {
											chains[I].splice((Inum - 1), 0 , rulen);
										} else {
											response = "iptables: Index of insertion too big.";
										}
									} else {
										response = "iptables: No chain/target/match by that name";
									}
								} else {
									response = errBool;
								}
							} else if (D) {
								if (chains[D] != null) {
									if (Dnum <= chains[D].length) {
										chains[D].splice((Dnum - 1), 1);
									} else {
										response = "iptables: Index of insertion too big.";
									}
								} else {
									response = "iptables: No chain/target/match by that name";
								}
							} else if (R) {
								var obj = createRule(m, p, dport, sport, j, i, v, s, d, o, ctstate,R);
								var errBool = obj.error;
								var rulen:Rule = obj.rule;
								if (!errBool) {
									if (chains[R] != null) {
										if (Rnum == -1) {
											response = "iptables v1.4.4: -R requires a rule number\nTry 'iptables -h' or 'iptables --help' for more information";
										} else if (Rnum <= chains[R].length) {
											delete chains[R][String(Rnum - 1)]
											chains[R][String(Rnum - 1)] = rulen;
										} else {
											response = "iptables: Index of insertion too big.";
										}
									} else {
										response = "iptables: No chain/target/match by that name";
									}
								} else {
									response = errBool;
								}
							} else if (Eold) {
								if (Eold == "PROHIBITED") {
									response = "iptables v1.4.4: Cannot rename default chains\nTry 'iptables -h' or 'iptables --help' for more information";
								} else if (Eold == "REQUIRES") {
									response = "iptables v1.4.4: -E requires old-chain-name and new-chain-name\nTry 'iptables -h' or 'iptables --help' for more information";
								} else if (Eold == "NONE") {
									response = "iptables: No chain/target/match by that name";
								} else {
									var obj = chains[Eold]
									delete chains[Eold]
									chains[Enew] = obj;
								}
							} else if (Pchain) {
								if (Pchain == "BAD") {
									response = "iptables v1.4.4: Bad policy name.\nTry 'iptables -h' or 'iptables --help' for more information";
								} else if (Pchain == "REQUIRES") {
									response = "iptables v1.4.4: -P requires a chain and a policy\nTry 'iptables -h' or 'iptables --help' for more information";
								} else if (Pchain == "NONE") {
									response = "iptables: No chain/target/match by that name";
								} else {
									chainPolicy[Pchain] = Pol;
								}
							} else if (F) {
								if (F == "ALL") {
									for (var chainKey:String in chains) {
										chains[chainKey] = new Array();
									}
								} else if (chains[F] != null) {
									chains[F] = new Array();
								} else {
									response = "iptables: No chain/target/match by that name";
								}
							}
							
						}
					} else if (cmd1 && cmd2) {
						response = "iptables v1.4.4: Cannot use " + cmd1 + " with " + cmd2 + "\n\nTry 'iptables -h' or 'iptables --help' for more information";
					} else {
						//No command
						if (badArg) {
							response = "Bad argument '" + badArg +"'\nTry 'iptables -h' or 'iptables --help' for more information";
						} else {
							response = "iptables v1.4.4: no command specified\nTry 'iptables -h' or 'iptables --help' for more information";
						}
					}
					if (help) {
						response = "iptables v1.4.21\n\nUsage: iptables -[ACD] chain rule-specification [options]   	\niptables -I chain [rulenum] rule-specification [options]   	\niptables -R chain rulenum rule-specification [options]\n   	iptables -D chain rulenum [options]\n   	iptables -[LS] [chain [rulenum]] [options]\n   	iptables -[FZ] [chain] [options]\n   	iptables -[NX] chain\n   	iptables -E old-chain-name new-chain-name\n   	iptables -P chain target [options]\n   	iptables -h (print this help information)\n\nCommands:\nEither long or short options are allowed.\n  --append  -A chain   	 Append to chain\n  --check   -C chain   	 Check for the existence of a rule\n  --delete  -D chain   	 Delete matching rule from chain\n  --delete  -D chain rulenum\n   			 Delete rule rulenum (1 = first) from chain\n  --insert  -I chain [rulenum]\n   			 Insert in chain as rulenum (default 1=first)\n  --replace -R chain rulenum\n   			 Replace rule rulenum (1 = first) in chain\n  --list	-L [chain [rulenum]]\n   			 List the rules in a chain or all chains\n  --list-rules -S [chain [rulenum]]\n   			 Print the rules in a chain or all chains\n  --flush   -F [chain]   	 Delete all rules in  chain or all chains\n  --zero	-Z [chain [rulenum]]\n  			 Zero counters in chain or all chains\n  --new 	-N chain   	 Create a new user-defined chain\n  --delete-chain\n        	-X [chain]   	 Delete a user-defined chain\n  --policy  -P chain target\n   			 Change policy on chain to target\n  --rename-chain\n        	-E old-chain new-chain\n   			 Change chain name, (moving any references)\nOptions:\n	--ipv4    -4   	 Nothing (line is ignored by ip6tables-restore)\n	--ipv6    -6   	 Error (line is ignored by iptables-restore)\n[!] --protocol    -p proto    protocol: by number or name, eg. `tcp'\n[!] --source    -s address[/mask][...]\n   			 source specification\n[!] --destination -d address[/mask][...]\n   			 destination specification\n[!] --in-interface -i input name[+]\n   			 network interface name ([+] for wildcard)\n --jump    -j target\n   			 target for rule (may load target extension)\n  --goto  	-g chain\n                          	jump to chain with no return\n  --match    -m match\n   			 extended match (may load extension)\n  --numeric    -n   	 numeric output of addresses and ports\n[!] --out-interface -o output name[+]\n   			 network interface name ([+] for wildcard)\n  --table    -t table    table to manipulate (default: `filter')\n  --verbose    -v   	 verbose mode\n  --wait    -w [seconds]    wait for the xtables lock\n  --line-numbers   	 print line numbers when listing\n  --exact    -x   	 expand numbers (display exact values)\n[!] --fragment    -f   	 match second or further fragments only\n  --modprobe=<command>   	 try to insert modules using this command\n  --set-counters PKTS BYTES    set the counter during insert/append\n[!] --version    -V   	 print package version."
					}
					updateFWText();
				}
				if (response) {
					var lines = response.split("\n").length
					var termPreSym = new TextField();
					mcTerminalPane.addChild(termPreSym);
					termPreSym.width = 20;
					termPreSym.height = 20;
					termPreSym.x = 5;
					termPreSym.y = currentTerminalY;
					termPreSym.border = false
					termPreSym.type = TextFieldType.DYNAMIC;
					termPreSym.text = ">";
					termPreSym.textColor = 0xFFFFFF;
					mcTerminalPane.addChild(termPreSym);

					newLine = new TextField();
					mcTerminalPane.addChild(newLine);
					newLine.width = 450;
					newLine.height = 20 + (15 * lines-1);
					newLine.x = 25;
					newLine.y = currentTerminalY;
					newLine.border = false
					newLine.type = TextFieldType.DYNAMIC;
					newLine.text = response;
					newLine.textColor = 0xFFFFFF;

					currentTerminalY = currentTerminalY + 5 + (15 * lines - 1);
				}
		}
		
		private function createRule(m:String, p:String, dport:String, sport:String, j:String, i:String, v:Boolean, s:String, d:String, o:String, ctstate:String, chain:String):Object
		{
			var prot:String = "all";
			var target:String = "";
			var source:String = "anywhere";
			var destination:String = "anywhere";
			var opt:String = "--";
			var iface = "";
			var x:String = "";
			var ssport = "";
			var ddport = "";
			
			var error = "";
			
			if (m) {
				if (m == "conntrack") {
					if (!ctstate) {				
						error = "iptables v1.4.4: conntrack: At least one option is required\nTry 'iptables -h' or 'iptables --help' for more information";
					}
				} else {
					error = "iptables v1.4.4: conntrack: At least one option is required\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (p) {
				var proto = p.toLowerCase();
				if (proto == "tcp" || proto == "udp" || proto == "udplite" || proto == "icmp" || proto == "esp" || proto == "ah" || proto == "sctp" || proto == "ipv6") {
					prot = proto
				} else {
					error = "iptables v1.4.4: unknown protocol '" + p + "' specified\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (sport) {
				if (prot == "tcp" || prot == "udp") {
					if (!(isNaN(Number(sport))) && Number(sport) < 5000) {
						x = prot + " spt:" + sport
						ssport = sport
					} else if (sport == "www" || sport == "ssh") {
						x = prot + " spt:" + sport
					} else if (sport.split(":").length == 2) {
						var port1 = sport.split(":")[0];
						var port2 = sport.split(":")[1];
						if (!(isNaN(Number(port1))) && Number(port1) < 5000 && !(isNaN(Number(port2))) && Number(port2) < 5000) {
							if (port1 > port2) {
								error = "iptables v1.4.4: invalid portrange (min > max)\nTry 'iptables -h' or 'iptables --help' for more information";
							} else {
								x = prot + " spts:" + port1 + ":" + port2 + " "
								ssport = port1 + ":" + port2
							}
						} else {
							error = "iptables v1.4.4: invalid port/service '" + sport + "' specified\nTry 'iptables -h' or 'iptables --help' for more information";
						}
					} else {
						error = "iptables v1.4.4: invalid port/service '" + sport + "' specified\nTry 'iptables -h' or 'iptables --help' for more information";
					}
				}
			}
			if (dport) {
				if (prot == "tcp" || prot == "udp") {
					if (!(isNaN(Number(dport))) && Number(dport) < 5000) {
						x += " " + prot + " dpt:" + dport
						ddport = dport
					} else if (dport == "www" || dport == "ssh") {
						x += " " +prot + " dpt:" + dport
					} else if (dport.split(":").length == 2) {
						var port1 = dport.split(":")[0];
						var port2 = dport.split(":")[1];
						if (!(isNaN(Number(port1))) && Number(port1) < 5000 && !(isNaN(Number(port2))) && Number(port2) < 5000) {
							if (port1 > port2) {
								error = "iptables v1.4.4: invalid portrange (min > max)\nTry 'iptables -h' or 'iptables --help' for more information";
							} else {
								x += " " +prot + " dpts:" + port1 + ":" + port2 + " "
								ddport = port1 + ":" + port2
							}
						} else {
							error = "iptables v1.4.4: invalid port/service '" + dport + "' specified\nTry 'iptables -h' or 'iptables --help' for more information";
						}
					} else {
						error = "iptables v1.4.4: invalid port/service '" + dport + "' specified\nTry 'iptables -h' or 'iptables --help' for more information";
					}
				}
			}
			if (j) {
				if (j == "ACCEPT" || j == "REJECT" || j == "DROP" || j == "LOG") {
					target = j		//log level warning on x? 
				} else {
					error = "iptables v1.4.4: Couldn't load target '" + p + "':/lib/xtables/libipt_drop.so: \ncannot open shared object file: No such file or directory\n\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (i) {
				if (chain == "INPUT") {
					iface = i;
				} else {
					error = "iptables v1.4.4: Can't use -i with " + chain + "\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (v) {
				trace("v not implemented")
			}
			if (s) {
				var sp = s.split(".");
				if (sp.length == 4 && !(isNaN(Number(sp[0]))) && !(isNaN(Number(sp[1])))&& !(isNaN(Number(sp[2])))&& !(isNaN(Number(sp[3])))) {
					if (Number(sp[0]) > 255 || Number(sp[1]) > 255 || Number(sp[2]) > 255 || Number(sp[3]) > 255) {
						error = "iptables v1.4.4: host/network '" + s + "' out of range\nTry 'iptables -h' or 'iptables --help' for more information";
					} else {
						source = s;
					}
				} else if (!isNaN(Number(s))) {
					var num:int = Number(s)
					var bytes:Array = new Array();
					bytes[0] = num & 0xFF;
					bytes[1] = (num >> 8) & 0xFF;
					bytes[2] = (num >> 16) & 0xFF;
					bytes[3] = (num >> 24) & 0xFF; 
					source = bytes.join(".");
				} else {
					error = "iptables v1.4.4: host/network '" + s + "' not found\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (d) {
				var sp = d.split(".");
				if (sp.length == 4 && !(isNaN(Number(sp[0]))) && !(isNaN(Number(sp[1])))&& !(isNaN(Number(sp[2])))&& !(isNaN(Number(sp[3])))) {
					if (Number(sp[0]) > 255 || Number(sp[1]) > 255 || Number(sp[2]) > 255 || Number(sp[3]) > 255) {
						error = "iptables v1.4.4: host/network '" + d + "' out of range\nTry 'iptables -h' or 'iptables --help' for more information";
					} else {
						destination = d;
					}
				} else if (!isNaN(Number(d))) {
					var num:int = Number(d)
					var bytes:Array = new Array();
					bytes[0] = num & 0xFF;
					bytes[1] = (num >> 8) & 0xFF;
					bytes[2] = (num >> 16) & 0xFF;
					bytes[3] = (num >> 24) & 0xFF; 
					destination = bytes.join(".");
				} else {
					error = "iptables v1.4.4: host/network '" + d + "' not found\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (o) {
				if (chain == "OUTPUT") {
					iface = o;
				} else {
					error = "iptables v1.4.4: Can't use -o with " + chain + "\nTry 'iptables -h' or 'iptables --help' for more information";
				}
			}
			if (ctstate) {
				if (m != "conntrack") {
					error = "iptables v1.4.4: unknown option '--ctstate'\nTry 'iptables -h' or 'iptables --help' for more information";
				} else {
					var states:Array = ctstate.split(",");
					var bad:String = "";
					states.sort();
					for (var ii:int = states.length-1; ii>0; --ii) {
						if (states[ii]===states[ii-1]) {
							states.splice(ii,1);
						} else if (states[ii] != "RELATED" || states[ii] != "ESTABLISHED" || states[ii] != "INVALID" || states[ii] != "NEW") {
							bad = states[ii]
						}
					}
					if (!bad) {
						x += " ctstate " + states.join(",");
					} else {
						error = "iptables v1.4.4: Bad ctstate '" +bad + "'\nTry 'iptables -h' or 'iptables --help' for more information";
					}
				}

			}

			var newRule:Rule = new Rule(target, prot, opt, source, destination, x,iface,ssport,ddport);
			var rtrn = new Object();
			rtrn.error = error;
			rtrn.rule = newRule;
			return rtrn;
		}
		
		private function playGame(e:Event):void 
		{
			menuStart.hideScreen();
			menuSettings.showsScreen();
			menuLevelSelect.showsScreen();
		}
		
		private function finishLevel(e:MouseEvent):void 
		{
			var feedback:String = "";
			var level:Object = levels[currLevel];
			var fail:Boolean = false;
			var testpkts:Array = level.answer;
			for (var pkt:String in testpkts) {
				var packet:Packet = testpkts[pkt];
				var ans:String = packet.answer[0];
				var outcome:String = "";
				for (var ruleKey:String in chains[packet.table]) {
					var rtrn = (chains[packet.table][ruleKey] as Rule).outcome(packet);
					if (rtrn != "UNMATCHED") {
						outcome = rtrn;
						break;
					}
				}
				if (outcome == "") {
					var out:String = chainPolicy[packet.table];
					if (ans != out) {
						feedback += "<font color=\"#DC143C\">"
						feedback += "    Test Packet (" + (Number(pkt) + 1) + "/" +testpkts.length + ") "
						if (packet.source) {
							feedback += "with source: " + packet.source
						}
						if (packet.destination) {
							feedback += " , destination: " + packet.destination
						}
						if (packet.protocol) {
							feedback += " , protocol: " + packet.protocol
						}
						if (packet.dport) {
							feedback += " , destination port: " + packet.dport
						}
						if (packet.sport) {
							feedback += " , source port: " + packet.sport
						}
						if (packet.table) {
							feedback += " at the " + packet.table + " chain"
						}
						feedback += " was sent to target " + out + " instead of " + ans + "\n";
						feedback += "</font>"
						fail = true;
					} else {
						feedback += "<font color=\"#228B22\">"
						feedback += "    Test Packet (" + (Number(pkt) + 1) + "/" +testpkts.length + ") "
						if (packet.source) {
							feedback += "with source: " + packet.source
						}
						if (packet.destination) {
							feedback += " , destination: " + packet.destination
						}
						if (packet.protocol) {
							feedback += " , protocol: " + packet.protocol
						}
						if (packet.dport) {
							feedback += " , destination port: " + packet.dport
						}
						if (packet.sport) {
							feedback += " , source port: " + packet.sport
						}
						if (packet.table) {
							feedback += " at the " + packet.table + " chain"
						}
						feedback += " was sent to target " + ans + " correctly\n";
						feedback += "</font>"
					}
				} else if (ans == outcome) {
						feedback += "<font color=\"#228B22\">"
						feedback += "    Test Packet (" + (Number(pkt) + 1) + "/" +testpkts.length + ") "
						if (packet.source) {
							feedback += "with source: " + packet.source
						}
						if (packet.destination) {
							feedback += " , destination: " + packet.destination
						}
						if (packet.protocol) {
							feedback += " , protocol: " + packet.protocol
						}
						if (packet.dport) {
							feedback += " , destination port: " + packet.dport
						}
						if (packet.sport) {
							feedback += " , source port: " + packet.sport
						}
						if (packet.table) {
							feedback += " at the " + packet.table + " chain"
						}
						feedback += " was sent to target " + ans + " correctly\n";
						feedback += "</font>"
				} else if (ans != outcome) {
						feedback += "<font color=\"#DC143C\">"
						feedback += "    Test Packet (" + (Number(pkt) + 1) + "/" +testpkts.length + ") "
						if (packet.source) {
							feedback += "with source: " + packet.source
						}
						if (packet.destination) {
							feedback += " , destination: " + packet.destination
						}
						if (packet.protocol) {
							feedback += " , protocol: " + packet.protocol
						}
						if (packet.dport) {
							feedback += " , destination port: " + packet.dport
						}
						if (packet.sport) {
							feedback += " , source port: " + packet.sport
						}
						if (packet.table) {
							feedback += " at the " + packet.table + " chain"
						}
						feedback += " was sent to target " + outcome + " instead of " + ans + "\n";
						feedback += "</font>"
						fail = true;
				}
			}
			if (!fail) {
				if (levels[currLevel].successfeedback) {
					feedback = levels[currLevel].successfeedback
				} else {
					feedback = "Hi, \n\n That seems to have done the trick! Here's what I tested and what you got right:\n\n" + feedback + "\n\nThere is plenty more to do so get back to work\n\nB,"
				}
			}
			if (fail && levels[currLevel].failfeedback) {
					feedback = levels[currLevel].failfeedback + feedback + "\n\nB,";
			} else if (fail) {
				feedback = "Hi, \n\n Unfortunately your solution has not solved the problem. Take another look at the breifing and then restart or continue to try again.\n\n A summary of what went wrong can be found below: \n\n" + feedback + "\n\nB,"
			}
			//feedback
			menuFeedback.update(feedback);
			menuFeedback.showsScreen(fail);
		}
		
		private function updateFWText():void {
			var txt = "										<font size=\"13\"><B>Firewall Rules</B></font size=\"13\">\n\n"
			for (var chain:String in chains) {
					if (chain != "ALL") {
						txt += "Chain " + chain +  " (policy "+chainPolicy[chain]+")\ntarget		prot opt source					destination\n";
						for (var rule:String in chains[chain]) {
							txt += (chains[chain][rule] as Rule).toRuleString();
						}
						txt += "\n";
					}
			}
			mcFirewallText.htmlText = txt
		}
		
		function clone(source:Object):* {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return(copier.readObject());
		}
		
		private function setupLevels():void 
		{
				var level1 = new Object();
				var level2 = new Object();
				var level3 = new Object();
				var level4 = new Object();
				var level5 = new Object();
				var level6 = new Object();
				var level7 = new Object();
				var level8 = new Object();
				var level9 = new Object();
				var level10 = new Object();
				var level11 = new Object();
				var level12 = new Object();
				var level13 = new Object();
				var level14 = new Object();
				var level15 = new Object();
				var level16 = new Object();
				var level17 = new Object();
				var level18 = new Object();
				var level19 = new Object();
				var level20 = new Object();

				//"Hi,\n\n\n\nB,";
				
				level1.briefing_easy = "Hi,\n\n   We have an urgent issue with the firewall, none of the staff can access the internet at all. Before you worry about safety I need you to get us back online immediately.\n\n<font size=\"13\"><B>  It seems like the policy for the firewalls INPUT and OUTPUT tables have been set to DROP so all incoming and outgoing packets are dropped by default.</B> </font size=\"13\">\n\n  You need to either change the default policy for these chains or add sufficient rules to allow internet access, \n\n  To edit the firewall you will need superuser privilege, which is gained by using “sudo” before the desired command.\n\n  To edit the firewall use the “iptables” flag followed by a series of commands and corresponding parameters. For example to change a chains default policy use the “-P” or “--policy” command followed by the chain name and desired default policy, valid policies are “DROP” , “ACCEPT” and “REJECT” \n\n<font size=\"13\"><B>   sudo iptables -P INPUT ACCEPT</B> </font size=\"13\">\n\n  To learn more about more commands or command structure you can use the “-h” or “--help” command i.e:\n\n<font size=\"13\"><B>   sudo iptables --help</B></font size=\"13\">\n\n  Once you are happy with the changes you have made to the firewall, click the “Submit” button to see if you have completed the task.\n\nB,";
				level1.briefing_medium = "Hi,\n\n    The firewall seems to be blocking the internet access for the office, we need this fixed right away\n\n  <font size=\"13\"><B>I suggest looking at the OUTPUT and INPUT table's default policy </B></font size=\"13\"> or adding some rules to the chains to allow traffic in and out, don’t worry about security at the moment \n\n  Try using <font size=\"13\"><B>-L </B></font size=\"13\">to list current rules and table policy, <font size=\"13\"><B>-A</B></font size=\"13\"> to append a rule to a table and <font size=\"13\"><B>-P</B></font size=\"13\"> to change a tables policy if needed, Don't forget to try <font size=\"13\"><B>--help</B></font size=\"13\"> for some information on how to use the iptable commands\n\n  <font size=\"13\"><B> To edit the firewall you will need superuser privilege, remember to type sudo before the 'iptables' command.\</B></font size=\"13\">\n\n   Once you are happy with the changes you have made to the firewall, click the “Submit” button to see if you have completed the task. \n\nB,";
				level1.briefing_hard = "Hi,\n\n	What's going on?\n\n  I can't get on the internet at all!\n\n  First day on the job and you've broken everything! \n\n  You better fix this immediately \n\nB,";
										//src	       dst    	sport dport	proto	ans		chain	chainsforstart
				var ans1_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans1_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT","");
				level1.answer = [ans1_1, ans1_2];
				var chainslvl1 = new Dictionary();
				var chainPolicylvl1 = new Dictionary();
				chainslvl1["INPUT"] = new Array();
				chainPolicylvl1["INPUT"] = "DROP";
				chainslvl1["FORWARD"] = new Array();
				chainPolicylvl1["FORWARD"] = "ACCEPT";
				chainslvl1["OUTPUT"] = new Array();
				chainPolicylvl1["OUTPUT"] = "DROP";
				chainslvl1["ALL"] = new Array();
				level1.chains = chainslvl1
				level1.chainsPolicy = chainPolicylvl1
				levels.push(level1);
				

				level2.briefing_easy = "Hi,\n\n   We are vulnerable to all malicious hackers out there, we need some protection.\n\n   I want you to update the firewall such that only incoming TCP packets on ports 80 and 443 are accepted and all others are dropped\n\n   To add a rule to a chain use the “-A” or “--append” command followed by the chain name on which the rule should be added, and also followed by a range of options which define the rule. For example the option “-j” or “--jump” tells the rule what to do with a packet that is a match with the main section of the rule, by default iptables allows four targets: “ACCEPT”, “REJECT”, “DROP” and “LOG”. Options for the rule include “-p” or “--proto” which specifies the protocol and “--dport” specifies the destination port, these options are used to match corresponding packets i.e:\n\n   <font size=\"13\"><B> sudo iptables -A INPUT -j ACCEPT --dport 80 -p tcp</B></font size=\"13\">\n\n   Remember that rules are applied by first match, try to think about your INPUT tables chosen default policy and if you need to add an extra rule at the end to specify what to do with unmatched packets.\n\nB,"
				level2.briefing_medium = "Hi,\n\n   We are vulnerable to all malicious hackers out there, we need some protection.\n\n   I want you to update the firewall such that only incoming TCP packets on ports 80 and 443 are accepted and all others are dropped\n\n   <font size=\"13\"><B>Try to use the insert “-I” or append “-A” commands along with “--dport” destination port, “-p” protocol and “-j” jump options to create your rules.</B></font size=\"13\">\n\n   Remember that rules are applied by first match, try to think about your INPUT tables chosen default policy and if you need to add an extra rule at the end to specify what to do with unmatched packets.\n\nB,"
				level2.briefing_hard = "Hi,\n\n   We are vulnerable to all malicious hackers out there, we need some protection.\n\n   I want you to update the firewall such that only incoming TCP packets on ports 80 and 443 are accepted and all others are dropped\n\n   \n\nB,"
				var ans2_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans2_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans2_3 = new Packet("139.130.4.5", "8.8.8.8", "", "22", "tcp", ["DROP"], "INPUT","");
				var ans2_4 = new Packet("139.130.4.5", "8.8.8.8", "", "133", "tcp", ["DROP"], "INPUT","");
				level2.answer = [ans2_1,ans2_2,ans2_3,ans2_4];
				levels.push(level2);
				level3.briefing_easy = "Hi,\n\n   I’m still not sold you’re the person for the job, I’ve tinkered with the firewall a little bit, let’s see if you can get things working correctly again!\n\n Use “-D” or “—delete” to remove a rule: \n\n    <font size=\"13\"><B>sudo iptables -D INPUT 3</B></font size=\"13\">\n\nB,";
				level3.briefing_medium = "Hi,\n\n   I’m still not sold you’re the person for the job, I’ve tinkered with the firewall a little bit, let’s see if you can get things working correctly again!\n\n Use “-D” or “—delete” to remove a rule.\n\nB,";
				level3.briefing_hard = "Hi,\n\n   I’m still not sold you’re the person for the job, I’ve tinkered with the firewall a little bit, let’s see if you can get things working correctly again!\n\nB,";
				var chainslvl3 = new Dictionary();
				var chainPolicylvl3 = new Dictionary();
				chainslvl3["INPUT"] = new Array();
				chainPolicylvl3["INPUT"] = "ACCEPT";
				chainslvl3["FORWARD"] = new Array();
				chainPolicylvl3["FORWARD"] = "DROP";
				chainslvl3["OUTPUT"] = new Array();
				chainPolicylvl3["OUTPUT"] = "ACCEPT";
				chainslvl3["ALL"] = new Array();  //target //proto //opt // source /dest //x iface port
				chainslvl3["INPUT"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "", "",""))
				chainslvl3["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:80","","","80"))
				chainslvl3["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:443","","","443"))
				chainslvl3["INPUT"].push(new Rule("DROP", "all", "", "anywhere", "anywhere", "", "", "",""))
				var ans3_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans3_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans3_3 = new Packet("139.130.4.5", "8.8.8.8", "", "22", "tcp", ["DROP"], "INPUT","");
				var ans3_4 = new Packet("139.130.4.5", "8.8.8.8", "", "133", "tcp", ["DROP"], "INPUT","");
				level3.answer = [ans3_1,ans3_2,ans3_3,ans3_4];
				level3.chains = chainslvl3
				level3.chainsPolicy = chainPolicylvl3
				levels.push(level3);
				
				level4.briefing_easy = "Hi,\n\n   If you’re going to work here I value efficiency, I want you to again fix the firewall that I have broken, but this time try to do it with as few commands as you can manage.  Use “-F” or “--flush” to delete all rules or all rules in a chain:\n\n<font size=\"13\"><B>sudo iptables -F OUTPUT</B></font size=\"13\">\n\nB,";
				level4.briefing_medium = "Hi,\n\n   If you’re going to work here I value efficiency, I want you to again fix the firewall that I have broken, but this time try to do it with as few commands as you can manage.  Use “-F” or “--flush” to delete all rules or all rules in a chain. \n\nB,";
				level4.briefing_hard = "Hi,\n\n   If you’re going to work here I value efficiency, I want you to again fix the firewall that I have broken, but this time try to do it with as few commands as you can manage.\n\nB,";
				var chainslvl4 = new Dictionary();
				var chainPolicylvl4 = new Dictionary();
				chainslvl4["INPUT"] = new Array();
				chainPolicylvl4["INPUT"] = "ACCEPT";
				chainPolicylvl4["FORWARD"] = "DROP";
				chainslvl4["OUTPUT"] = new Array();
				chainslvl4["FORWARD"] = new Array();
				chainPolicylvl4["OUTPUT"] = "ACCEPT";
				chainslvl4["ALL"] = new Array();  //target //proto //opt // source /dest //x iface port
				chainslvl4["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:80","","","80"))
				chainslvl4["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:443","","","443"))
				chainslvl4["INPUT"].push(new Rule("DROP", "all", "", "anywhere", "anywhere", "", "", "",""))
				chainslvl4["OUTPUT"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["OUTPUT"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["OUTPUT"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["OUTPUT"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["OUTPUT"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["FORWARD"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["FORWARD"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","",""))
				chainslvl4["FORWARD"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","", ""))
				chainslvl4["FORWARD"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","", ""))
				chainslvl4["FORWARD"].push(new Rule("REJECT", "all", "", "anywhere", "anywhere", "", "","", ""))
				var ans4_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans4_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans4_3 = new Packet("139.130.4.5", "8.8.8.8", "", "22", "tcp", ["DROP"], "INPUT","");
				var ans4_4 = new Packet("139.130.4.5", "8.8.8.8", "", "133", "tcp", ["DROP"], "INPUT", "");
				var ans4_5 = new Packet("8.8.8.8", "8.8.8.8", "", "22", "tcp", ["ACCEPT"], "OUTPUT","");
				var ans4_6 = new Packet("10.10.10.10", "20.20.20.20", "", "13", "tcp", ["DROP"], "FORWARD","");
				level4.chains = chainslvl4
				level4.chainsPolicy = chainPolicylvl4
				level4.answer = [ans4_1,ans4_2,ans4_3,ans4_4,ans4_5,ans4_6];
				levels.push(level4);
				
				
				var chainslvl5 = new Dictionary();
				var chainPolicylvl5 = new Dictionary();
				chainslvl5["INPUT"] = new Array();
				chainslvl5["OUTPUT"] = new Array();
				chainslvl5["FORWARD"] = new Array();
				chainPolicylvl5["INPUT"] = "ACCEPT";
				chainPolicylvl5["FORWARD"] = "DROP";
				chainPolicylvl5["OUTPUT"] = "ACCEPT";
				level5.briefing_easy = "Hi,\n\n    One of the staffers needs to use SMP and as such inserted a rule into the INPUT chain.\n\n   It seems like they used the incorrect port number, SMP by default runs on port <font size=\"13\"><B>445</B></font size=\"13\"> use the “-R” or “--replace” command to change the incorrect rule to the correct rule with the appropriate port i.e:\n\n<font size=\"13\"><B>sudo iptables -R 5 --dport 123 -j ACCEPT -p tcp</B></font size=\"13\">\n\nB,";;
				level5.briefing_medium = "Hi,\n\n    One of the staffers needs to use SMP and as such inserted a rule into the INPUT chain.\n\n   It seems like they used the incorrect port number, SMP by default runs on port <font size=\"13\"><B>445</B></font size=\"13\"> use the “-R” or “--replace” command to change the incorrect rule to the correct rule with the appropriate port.\n\nB,";;
				level5.briefing_hard = "Hi,\n\n    One of the staffers needs to use SMP and as such inserted a rule into the INPUT chain.\n\n   It seems like they used the incorrect port number, SMP by default runs on port <font size=\"13\"><B>445</B></font size=\"13\"> use the replace command to change the incorrect rule to the correct rule with the appropriate port.\n\nB,";;
				chainslvl5["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:80", "","", "80"))
				chainslvl5["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:111","","","111"))
				chainslvl5["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:443","","","443"))
				chainslvl5["INPUT"].push(new Rule("DROP", "all", "", "anywhere", "anywhere", "", "","", ""))
				var ans5_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans5_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans5_5 = new Packet("139.130.4.5", "8.8.8.8", "", "455", "tcp", ["ACCEPT"], "INPUT", "");
				var ans5_6 = new Packet("139.130.4.5", "8.8.8.8", "", "111", "tcp", ["DROP"], "INPUT", "");
				var ans5_3 = new Packet("139.130.4.5", "8.8.8.8", "", "22", "tcp", ["DROP"], "INPUT","");
				var ans5_4 = new Packet("139.130.4.5", "8.8.8.8", "", "133", "tcp", ["DROP"], "INPUT","");
				level5.chains = chainslvl5
				level5.chainsPolicy = chainPolicylvl5
				level5.answer = [ans5_1,ans5_2,ans5_3,ans5_4,ans5_5,ans5_6];
				levels.push(level5);
				

				var chainslvl6 = new Dictionary();
				var chainPolicylvl6 = new Dictionary();
				chainslvl6["INPUT"] = new Array();
				chainslvl6["OUTPUT"] = new Array();
				chainslvl6["FORWARD"] = new Array();
				chainPolicylvl6["INPUT"] = "ACCEPT";
				chainPolicylvl6["FORWARD"] = "DROP";
				chainPolicylvl6["OUTPUT"] = "DROP";
				level6.briefing_easy = "Hi,\n\n   Blocking outbound traffic is of benefit in limiting what an attacker can do once they've compromised a system on the network.\n\n   As such I’d like to move forward with a default policy change of drop on our OUTPUT chain.\n\n I’ve added the policy change already I need you to add the output rules of the corresponding input rules that you have previously implemented.\n\n   Remember that for outgoing rules we can use “--sport” to specify the source port:\n\n    <font size=\"13\"><B>sudo iptables -A  OUTPUT –j ACCEPT –p tcp –sport 80</B></font size=\"13\">\n\nB,";
				level6.briefing_medium = "Hi,\n\n   Blocking outbound traffic is of benefit in limiting what an attacker can do once they've compromised a system on the network.\n\n   As such I’d like to move forward with a default policy change of drop on our OUTPUT chain.\n\n I’ve added the policy change already I need you to add the output rules of the corresponding input rules that you have previously implemented.\n\n   Remember that for outgoing rules we can use “--sport” to specify the source port.\n\nB,";
				level6.briefing_hard = "Hi,\n\n   Blocking outbound traffic is of benefit in limiting what an attacker can do once they've compromised a system on the network.\n\n   As such I’d like to move forward with a default policy change of drop on our OUTPUT chain.\n\n I’ve added the policy change already I need you to add the output rules of the corresponding input rules that you have previously implemented.\n\nB,";
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:80", "", "","80"))
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:455","","","455"))
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:443","","","443"))
				chainslvl6["INPUT"].push(new Rule("DROP", "all", "", "anywhere", "anywhere", "", "","", ""))
				var ans6_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans6_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans6_3 = new Packet("139.130.4.5", "8.8.8.8", "", "455", "tcp", ["ACCEPT"], "INPUT", "");
				var ans6_4 = new Packet("139.130.4.5", "8.8.8.8", "80", "", "tcp", ["ACCEPT"], "OUTPUT","");
				var ans6_5 = new Packet("139.130.4.5", "8.8.8.8", "443", "", "tcp", ["ACCEPT"], "OUTPUT", "");
				var ans6_6 = new Packet("139.130.4.5", "8.8.8.8", "455", "", "tcp", ["ACCEPT"], "OUTPUT", "");
				level6.chains = chainslvl6
				level6.chainsPolicy = chainPolicylvl6
				level6.answer = [ans6_1,ans6_2,ans6_3,ans6_4,ans6_5,ans6_6];
				levels.push(level6);
				
				var chainslvl7 = new Dictionary();
				var chainPolicylvl7 = new Dictionary();
				chainslvl7["INPUT"] = new Array();
				chainslvl7["OUTPUT"] = new Array();
				chainslvl7["FORWARD"] = new Array();
				chainPolicylvl7["INPUT"] = "DROP";
				chainPolicylvl7["FORWARD"] = "DROP";
				chainPolicylvl7["OUTPUT"] = "DROP";
				level7.briefing_easy = "Hi,\n\n    There has been word of a malicious attacker at the IP of <font size=\"13\"><B>9.9.9.9</B></font size=\"13\">\n\n  Update the firewall to pre-emptively protect us against this by rejecting all packets from that IP. Use “-s” or “--source” as an option to specify the IP address that a rule pertains to.\n\n<font size=\"13\"><B>sudo iptables -A INPUT -s 9.9.9.9</B></font size=\"13\">\n\nB,";
				level7.briefing_medium = "Hi,\n\n    There has been word of a malicious attacker at the IP of <font size=\"13\"><B>9.9.9.9</B></font size=\"13\">\n\n  Update the firewall to pre-emptively protect us against this by rejecting all packets from that IP. Use “-s” or “--source” as an option to specify the IP address that a rule pertains to.\n\nB,";
				level7.briefing_hard = "Hi,\n\n    There has been word of a malicious attacker at the IP of <font size=\"13\"><B>9.9.9.9</B></font size=\"13\">\n\n  Update the firewall to pre-emptively protect us against this by rejecting all packets from that IP.\n\nB,";
				chainslvl7["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:80", "", "","80"))
				chainslvl7["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:455","","","455"))
				chainslvl7["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:443","","","443"))
				chainslvl7["OUTPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp spt:80", "", "80",""))
				chainslvl7["OUTPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp spt:455","","455",""))
				chainslvl7["OUTPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp spt:443","","443",""))
				var ans7_1 = new Packet("139.130.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans7_2 = new Packet("139.130.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans7_3 = new Packet("9.9.9.9", "8.8.8.8", "", "80", "tcp", ["REJECT"], "INPUT", "");
				var ans7_4 = new Packet("139.130.4.5", "8.8.8.8", "", "333", "tcp", ["DROP"], "INPUT", "");
				var ans7_5 = new Packet("9.9.9.9", "8.8.8.8", "", "22", "tcp", ["REJECT"], "INPUT", "");
				var ans7_6 = new Packet("9.9.9.9", "8.8.8.8", "", "", "udp", ["REJECT"], "INPUT", "");
				level7.chains = chainslvl7
				level7.chainsPolicy = chainPolicylvl7
				level7.answer = [ans7_1,ans7_2,ans7_3,ans7_4,ans7_5,ans7_6];
				levels.push(level7);
				
				level8.briefing_easy = "";
				level8.briefing_medium = "";
				level8.briefing_hard = "";
				level8.answer = [];
				//levels.push(level8);
				
				level9.briefing_easy = "";
				level9.briefing_medium = "";
				level9.briefing_hard = "";
				level9.answer = [];
				//levels.push(level9);
				
				level10.briefing_easy = "";
				level10.briefing_medium = "";
				level10.briefing_hard = "";
				level10.answer = [];
				//levels.push(level10);
				
				level11.briefing_easy = "";
				level11.briefing_medium = "";
				level11.briefing_hard = "";
				level11.answer = [];
				//levels.push(level11);
				
				level12.briefing_easy = "";
				level12.briefing_medium = "";
				level12.briefing_hard = "";
				level12.answer = [];
				//levels.push(level12);
				
				level13.briefing_easy = "";
				level13.briefing_medium = "";
				level13.briefing_hard = "";
				level13.answer = [];
				//levels.push(level13);
				
				level14.briefing_easy = "";
				level14.briefing_medium = "";
				level14.briefing_hard = "";
				level14.answer = [];
				//levels.push(level14);
				
				level15.briefing_easy = "";
				level15.briefing_medium = "";
				level15.briefing_hard = "";
				level15.answer = [];
				//levels.push(level15);
				
				level16.briefing_easy = "";
				level16.briefing_medium = "";
				level16.briefing_hard = "";
				level16.answer = [];
				//levels.push(level16);
				
				level17.briefing_easy = "";
				level17.briefing_medium = "";
				level17.briefing_hard = "";
				level17.answer = [];
				//levels.push(level17);
				
				level18.briefing_easy = "";
				level18.briefing_medium = "";
				level18.briefing_hard = "";
				level18.answer = [];
				//levels.push(level18);
				
				level19.briefing_easy = "";
				level19.briefing_medium = "";
				level19.briefing_hard = "";
				level19.answer = [];
				//levels.push(level19);
				
				level20.briefing_easy = "";
				level20.briefing_medium = "";
				level20.briefing_hard = "";
				level20.answer = [];
				//levels.push(level20);

		}
	}
}

class Packet {
	
	public var source:String;
	public var destination:String;
	public var sport:String;
	public var dport:String;
	public var protocol:String;
	public var table:String
	public var answer:Array;
	public var iface:String;
	
	public function Packet(src:String, dst:String, sport:String, dport:String, proto:String, ans:Array,table:String,iface:String) 
	{
		this.source = src;
		this.destination = dst;
		this.sport = sport;
		this.dport = dport;
		this.protocol = proto;
		this.answer = ans;
		this.table = table;
		this.iface = iface;
	}
}

class Rule {
	
	public var target:String;
	public var prot:String;
	public var opt:String;
	public var source:String;
	public var destination:String;
	public var options:String;
	public var iface:String;
	public var sport:String;
	public var dport:String;
	
	public function clone():Rule {
		var c:Rule = new Rule(this.target,this.prot,this.opt,this.source,this.destination,this.options,this.iface,this.sport,this.dport)
		return c;
		
	}
	
	public function Rule(target:String, prot:String, opt:String, source:String, destination:String, options:String, iface:String, sport:String,dport:String) 
	{
		this.target = target;
		this.prot = prot;
		this.opt = opt;
		this.source = source;
		this.destination = destination;
		this.options = options;
		this.iface = iface;
		this.sport = sport;
		this.dport = dport;
		
	}
	public function toRuleString():String {
		var s:String = target
		var tab = ""
		if (s == "DROP") {
			s += "	"
		} else if (s == "LOG") {
			s += "	"
		} else if (s == "") {
			s += "		"
		}
		s+= "	"
		if (source == "anywhere") {
			tab = "				"
		} else if (source.length > 6) {
			tab = "					"
		} else if (source.length > 10) {
			tab = "	 	"
		} else if (source.length > 14) {
			tab = "	"
		}
		var rule:String = s + prot + "	--	" + source + tab + destination + "				" + options + "\n";
		return rule;
	}
	
	public function outcome(packet:Packet):String {
		if ((packet.protocol == prot || prot == "all") && (packet.source == source || source == "anywhere") && (packet.destination == destination || destination == "anywhere") && (!(packet.iface) || packet.iface == iface) && (!(sport) || (sport == packet.sport)) && (!(dport) || dport == packet.dport)) {
			if (target) {
				return target;
			} else {
				return "UNMATCHED";	//Is actually matched just has no target in the specified rule, so treat as if no action/ummatched
			}
		} else {
			return "UNMATCHED";
		}
	}
}


/*
index too big on "sudo iptables -I INPUT" on an empty table

sudo ipdasdas - sudo command not fgound!

pressing settings on breifing does jack... fucking menu stuff all messed
*/


/*

				var chainslvl6 = new Dictionary();
				var chainPolicylvl6 = new Dictionary();
				chainslvl6["INPUT"] = new Array();
				chainslvl6["OUTPUT"] = new Array();
				chainslvl6["FORWARD"] = new Array();
				chainPolicylvl6["INPUT"] = "ACCEPT";
				chainPolicylvl6["FORWARD"] = "DROP";
				chainPolicylvl6["OUTPUT"] = "ACCEPT";
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:80","","80"))
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:443","","443"))
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:455","","443"))
				chainslvl6["INPUT"].push(new Rule("DROP", "all", "", "anywhere", "anywhere", "", "", ""))
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:ssh","","22"))
				chainslvl6["INPUT"].push(new Rule("ACCEPT", "tcp", "", "139.122.5.5", "8.8.8.8", " tcp dpt:ssh","","22"))
				chainslvl6["OUTPUT"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:ssh","","22"))
				chainslvl6["OUTPUT"].push(new Rule("ACCEPT", "tcp", "", "139.122.5.5", "8.8.8.8", " tcp dpt:ssh","","22"))
				chainslvl6["FORWARD"].push(new Rule("ACCEPT", "tcp", "", "anywhere", "anywhere", " tcp dpt:ssh","","22"))
				chainslvl6["FORWARD"].push(new Rule("ACCEPT", "tcp", "", "139.122.5.5", "8.8.8.8", " tcp dpt:ssh","","22"))
				chainslvl6["FORWARD"].push(new Rule("ACCEPT", "tcp", "", "139.122.5.5", "139.122.5.5", " tcp dpt:ssh","","22"))
				chainslvl6["FORWARD"].push(new Rule("ACCEPT", "tcp", "", "8.8.8.8", "8.8.8.8", " tcp dpt:ssh","","22"))
				var ans6_1 = new Packet("131.30.4.5", "8.8.8.8", "", "80", "tcp", ["ACCEPT"], "INPUT","");
				var ans6_2 = new Packet("133.20.4.5", "8.8.8.8", "", "443", "tcp", ["ACCEPT"], "INPUT", "");
				var ans6_3 = new Packet("131.1.2.1", "8.8.8.8", "", "455", "tcp", ["ACCEPT"], "INPUT", "");
				var ans6_4 = new Packet("131.1.2.1", "8.8.8.8", "", "22", "tcp", ["ACCEPT"], "INPUT", "");
				var ans5_5 = new Packet("139.130.4.5", "8.8.8.8", "", "133", "tcp", ["DROP"], "INPUT", "");
*/