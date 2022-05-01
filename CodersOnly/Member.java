import java.io.Serializable;

public class Member implements Serializable
{
	String name; //created name variable required for member
	int year; //created year variable required for member
	
	MemberList<Member> memberList; // created my member list
	InterestList<Interest> interestList; // created my interest list
	CompatibilityList<Compatibility> compatibilityList; //created my compatibilities list
	
	public Member(String names, int years) //member constructor
	{
		name = names;
		year = years;
		
	}
	
	public void setLoI(InterestList<Interest> listOfInterests) //setter interest InterestList
	{
		interestList = listOfInterests;
	}
	public void setLoM(MemberList<Member> listOfMembers) //setter member MemberList
	{
		memberList = listOfMembers;
	}
	public void setLoC(CompatibilityList<Compatibility> listOfCompatibility) //setter for compatibility CompatibilityList
	{
		compatibilityList = listOfCompatibility;
	}
	
	public CompatibilityList<Compatibility> getLoC() //getter for collection of compatibilities
	{
		return compatibilityList;
	}
	public InterestList<Interest> getLoI() //getter for collection of interests
	{
		return interestList;
	}
	public MemberList<Member> getLoM() //getter for collection of members
	{
		return memberList;
	}
	
	public String getName() //getter for member's name
	{
		return name;
	}
	
	public int getYear() //getter for member's year
	{
		return year;
	}
	
	public void setName(String name)
	{
		this.name = name;
	}
	public void setYear(int year)
	{
		this.year = year;
	}
	
	public String toString() //toString sentence for members
	{
		String yearName = ""; //year not ""
		switch(year)
		{
			case 1: yearName = "Freshman";
			break;
			case 2: yearName = "Sophomore";
			break;
			case 3: yearName = "Junior";
			break;
			case 4: yearName = "Senior";
			break;
			case 5: yearName = "CS Student with Degree";
			break;
		}
		String sentence = "Name: " + this.name + "\nYear: " + this.year + " " + yearName + "\n";
		return sentence;
	}
	
	public int compCalculation(Member testMember) //calculates the compatibility based on the requirements specified
	{											//cycles through using for each loops
		int topicCalculation = 0;
		boolean topicFound = false;
		
		for(Interest listA: testMember.getLoI())
		{
			for(Interest listB: this.getLoI())
			{
				if(listA.getInterestName().equalsIgnoreCase(listB.getInterestName()))
				{
					topicCalculation +=  (listA.getInterestLevel() * listB.getInterestLevel());
					topicFound = true;
				}
				
			}
			if(!topicFound)
			{
				topicCalculation += (listA.getInterestLevel()/2);
				
			}
		}
		

		return topicCalculation;
	}
}
