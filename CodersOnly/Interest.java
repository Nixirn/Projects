import java.io.Serializable;

public class Interest implements Serializable, Comparable<Interest>
{

	private String interestName;
	private Integer interestLevel;
	
	public Interest(String name, int interestLevel) //interest constructor
	{
		this.interestName = name;
		this.interestLevel = interestLevel;
	}
	
	public String getInterestName() //getter for interest name
	{
		return interestName;
	}
	public int getInterestLevel() //getter for interest level
	{
		return interestLevel;
	}
	
	public void setInterestName(String name)
	{
		interestName = name;
	}
	public void setInterestLevel(int level)
	{
		interestLevel = level;
	}

	
	public int compareTo(Interest level) //compare to for interest level when listing out the member's interests
	{
		return level.getInterestLevel() - this.getInterestLevel();
	}

}
