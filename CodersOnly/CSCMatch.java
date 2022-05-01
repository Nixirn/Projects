import java.io.IOException;
import java.util.Iterator;
import java.util.Scanner;

public class CSCMatch {

	public static void main(String[] args) 
	{
		boolean doAgain = true;
		int year = 0;
		String name = "";
		Scanner input = new Scanner(System.in);
		MemberList<Member> member = new MemberList<Member>();
		int navigate = 0;
		
		do	
		{
			CompatibilityList<Compatibility> compatibility = new CompatibilityList<Compatibility>();
			InterestList<Interest> interest = new InterestList<Interest>();
			//took me freaking ages but apparently these god damn lists need to be inside the do/while loop
			//for it to freaking work correctly gdi
			//I assume because since the do while never ends, they never have a chance to correctly update.
			//y'all are welcome legit spent like 3 hours trying to figure this kink out :'(
			Member membObject = new Member(name, year);// needs to go inside loop, otherwise list updates incorrectly
			
			do
			{
	
					System.out.println("Welcome to CSC Match!");
					System.out.println("Use the numbers to navigate through the menu");
					System.out.println("[1] Load the Members");
					System.out.println("[2] Save the Members");
					System.out.println("[3] List All Members");
					System.out.println("[4] Add a Member");
					System.out.println("[5] Remove a Member");
					System.out.println("[6] List Member");
					System.out.println("[7] Add an Interest to a Member");
					System.out.println("[8] Quit");
					
			
						try 
						{
							System.out.println("Enter a number when you're ready");
							navigate = input.nextInt();
						}
						catch(Exception e)
						{
							
							System.out.println(e.getMessage());
							System.out.println("Please input a valid number");
							navigate = 0;
							navigate = input.nextInt();
							
						}
				}
			while(navigate == 0);
	
			
				switch(navigate)
				{
					case 1: //load a user specified files with members
						boolean fileLoaded = false;
						do 
						{
							try
							{
								System.out.println("Enter the name of the file you would like to load");
								input.nextLine();
								String fileInput = input.nextLine(); //takes user input (file name)
								
								member = member.load(fileInput); //sets the member list object equal to the data in the input file
								
								System.out.println("Successfully loaded " + fileInput + "!");
								System.out.println();
								System.out.println();
								fileLoaded = true; //if successful, it'll trigger this boolean and end the do-while, breaking the switch case and sending you back to main menu
							}
							catch(IOException | ClassNotFoundException e)
							{
								//System.out.println(e.getMessage());
								System.out.println("Could not find file; please enter new filename.");
								fileLoaded = false;
							}
						}
						while(fileLoaded == false); //if an error occurs in loading the file, it'll keep asking for the file name
						break;
						
					case 2: //save a user specified file
						boolean fileSaved = false;
						do
						{
							
							try
							{
								System.out.println("Enter the name of the file to be saved.");
								input.nextLine();
								String fileSave = input.nextLine(); //asks for the user to input the name of the file to be saved
								member.save(fileSave);//once the file name is input, then the member collection that holds the data of the file will be saved under the input file name
								System.out.println("Your file was successfully saved!");
								System.out.println();
								System.out.println();
								fileSaved = true; //like the load, triggers boolean if the file was saved then breaks the case and returns you to the menu
							}
							catch(IOException | ClassNotFoundException e)
							{
								System.out.println("File was not saved, double check your input");
								fileSaved = false;
								System.out.println();
								System.out.println();
							}
							
						}
						while(fileSaved == false); //if an exception is caught, will keep repeating 
						break;
						
					case 3: //print all members
						if(member.isEmpty())
						{
							System.out.println("There are no members!");
							System.out.println();
							System.out.println();
						} 
						else
						{
							for(Member a: member)
							{
								System.out.println(a.getName());
							}
						}
						
						break;
					case 4: //add a member
						//Member membObject = new Member(name, year); //moved this from outside to this specific case; resolved duplicate entry
						boolean memberExists = false;
						boolean validYear = true;
						boolean addAnother = false;
						String nameAdd = "";
						
						input.nextLine();
						System.out.println("What is the member's name?");//Asks user what member name is; use setter to set the name
						nameAdd = input.nextLine();
						membObject.setName(nameAdd);
						
						do
						{	
							for(Member a: member) //for each loop; sifts through for each member a in ArrayList<member> member then checks the names in the collection with the input name
							{
								if (membObject.getName().equalsIgnoreCase(a.getName()))
								{
									//System.out.println(membObject.getName() + " " + a.getName());
									memberExists = true;
									System.out.println("This member already exists; please enter a unique name");
									//input.nextLine();
									nameAdd = input.nextLine();
									membObject.setName(nameAdd);
									break;

								}
								else
								{
									System.out.println("test");
									memberExists = false;
								}
							}
							
							
						}
						while(memberExists == true); //use == lol not =; or you'll assign yourself into an infinite loop
						
						do
						{
							System.out.println("What year is the member?");
							System.out.println("[1] Freshman");
							System.out.println("[2] Sophomore");
							System.out.println("[3] Junior");
							System.out.println("[4] Senior");
							System.out.println("[5] CS Student with Degree");
							try
							{
								membObject.setYear(input.nextInt());
								
								if(membObject.getYear() >= 6 || membObject.getYear() <=0)
								{
									throw new Exception();
								}
								
								else 
								{
									validYear = true;
								}
							}
							catch(Exception e)
							{
								System.out.println("Please enter a valid choice");
								validYear = false;
							}
								
						}
						while(validYear == false);
						
						input.nextLine();
						member.addToRear(membObject);
						membObject.setLoI(interest);//when a member is added to the list, the interest list is set to that specific member
						membObject.setLoC(compatibility);//when a member is added to the list, the compatibility list is also set to that specific member
						
						//System.out.println(membObject.toString());
						
						
						break;
					case 5: //remove member
						if(member.isEmpty())
						{
							System.out.println("You cannot remove members because:");
							System.out.println("There are currently no members");
						}	
						else
						{
							boolean checkMember = false;
							
							input.nextLine();
							System.out.println("Which member would you like to remove?");
							String removeMember = input.nextLine();
														
							for(Member a: member)
							{
								if(a.getName().equalsIgnoreCase(removeMember))
								{
									member.remove(a);
									checkMember = true;
									break;
								}

							}
							if(!checkMember == true)
							{
								System.out.println("User was not found or does not exist.");
							}
						}
						break;
					case 6:
						boolean listAgain = false;
						String listName;
						Member listedMemb = null;
						System.out.println("Which member would you like to list?");
						input.nextLine();
						listName = input.nextLine();
	
						do
						{

							for(Member a: member)
							{
								if(a.getName().equalsIgnoreCase(listName))
								{
									listedMemb = a;
									
									for(Member b: member)
									{
										String memberA = listedMemb.getName();
										String memberB = b.getName();
										int topicCalc = listedMemb.compCalculation(b);
										
										if(!memberB.equalsIgnoreCase(memberA))
										{
											Compatibility compObject = new Compatibility(memberA, memberB, topicCalc);
											compatibility.add(compObject);
										}
									
									}
									break;
								}
								
							}
							
							if(listedMemb != null)
							{
								System.out.println(listedMemb.toString());
								System.out.println();
								System.out.println("Top Matches:");

								if(compatibility.size() > 5)
								{
										System.out.println(compatibility.topMatches(compatibility.size() - 5, compatibility.size()));	
								}
								else
								{
									System.out.println(compatibility.toString());
								}
								
							}
							else
							{
								System.out.println("User does not exist.");
								System.out.println();
								System.out.println();
							}
						}
						while(listAgain == true);
						
						
						
						break;
					case 7:
						boolean memberFound = false;
						boolean validInterestChoice = false;
						boolean addRemoveMore = true;
						Member found = null;
						int interestChoice = 0;
	
						if(member.isEmpty())
						{
							System.out.println("You cannot add any interests because \nthere are no members.");
						}
						
						else
						{
							System.out.println("Which member would you like to add an interest to?");
							input.nextLine();
							String findMember = input.nextLine();
					do
					{
						do 
						{
							for(Member a: member)
							{
								if (a.getName().equalsIgnoreCase(findMember))
								{
									found = a;
									memberFound = true;
									break;
								}
							}
							if(found == null)
							{
								System.out.println("Sorry, member was not found.");
								System.out.println("Enter a valid member.");
								findMember = input.nextLine();
							}
						}
						while(memberFound == false);
							
							
							if (found != null)
							{	
								do
								{
									try
									{
	
										System.out.println("Would you like to:\n[1]Add Interest\n[2]Remove Interest");
										interestChoice = input.nextInt();
										if(interestChoice == 1 | interestChoice == 2)
											validInterestChoice = true;
										else if(interestChoice != 1 | interestChoice != 2)
										{
											throw new Exception();
										}
											
									}
									catch(Exception e)
									{
										System.out.println("Invalid choice. Please enter [1] or [2].");
										validInterestChoice = false;
									}
								}
								while(validInterestChoice == false);
								
								
								switch(interestChoice)
								{
									case 1://add
										boolean validInterestLevel = false;

										System.out.println("Which interest would you like to add?");
										input.nextLine();
										String interestAdd = input.nextLine();
										System.out.println("What would you say that member's level of interest is?");		
									do 
									{
										try
										{
											int interestLevelAdd = input.nextInt();
											
											for(Interest a: found.getLoI())
											{
												if(a.getInterestName().equalsIgnoreCase(interestAdd))
												{
													a.setInterestName(interestAdd);
													validInterestLevel = true;
													break;
												}
											}
											
											if(interestLevelAdd > 10 | interestLevelAdd < 0)
											{
												throw new Exception();
											}
											
											Interest addInterest = new Interest(interestAdd, interestLevelAdd);
											found.getLoI().add(addInterest);
											validInterestLevel = true;
										
											break;
										}
										catch(Exception exception)
										{
											System.out.println("Please input a number [1-10]");
											validInterestLevel = false;
										}
									}
									while(validInterestLevel == false);
								
									System.out.println("Would you like to add another interest? [Y/N]");
									input.nextLine();
									String anotherInterest = input.nextLine();
									if(anotherInterest.equalsIgnoreCase("y"))
									{
										addRemoveMore = true;
									}
									else
									{
										addRemoveMore = false;
									}
									
									break;
									
									case 2: //remove
										
									    boolean fou = false;
									    
									    while (fou) {
									    	
									    	System.out.println("Enter the name of the intrest you would like to remove");
										    String remove = input.nextLine();
									    	
										    for (Intrest b: found.getLoI()) {
										    	
										    	if (b.getInterestName().equalsIgnoreCase(remove)) 
										    	{
										    		found.getLoI().remove(remove);
										    		System.out.println("Intrest " + remove + " for " + found + " was removed successfully");
										    		fou = true;
										    		break;
										    	}
										    	else {
										    		System.out.println("Intrest " + remove + " was not found, try again!");
										    		fou = false;
										    		
										    	}
										    }
									    }
										
										
										System.out.println("Would you like to add or remove another interest? [Y/N]");
										anotherInterest = input.nextLine();
										if(anotherInterest.equalsIgnoreCase("y") ? addRemoveMore == true : addRemoveMore == false);
										
										break;
										
								}
								
							}
						}
					while(addRemoveMore == true);
					}
					
					

						break;
					case 8: //quit
						String quitChoice = null;
						System.out.println("Before quitting, would you like to save your file? [Y] or [N]");
						input.nextLine();
						quitChoice = input.nextLine();
						if(quitChoice.equalsIgnoreCase("y"))
						{
							boolean quitSaved = false;
							do
							{
								try
								{
									System.out.println("Enter the name of the file to be saved.");
									String fileSave = input.nextLine();
									member.save(fileSave);
									System.out.println("Your file was successfully saved!");
									System.out.println("Now terminating program.");
									System.out.println("Goodbye.");
									quitSaved = true;
									
								}
								catch(IOException | ClassNotFoundException e)
								{
									System.out.println("File was not saved, double check your input");
									quitSaved = false;

								}
							}
							while(quitSaved == false);	
							System.exit(1);
						}
						else
						{
							System.out.println("Okay, now exiting.");
							System.exit(1);
						}
						
						break;
						
				}
		}
		while(navigate != 8);

	}
}
