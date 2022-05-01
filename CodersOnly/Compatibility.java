import java.io.Serializable;

public class Compatibility implements Serializable, Comparable<Compatibility>
{
	String memberA;
	String memberB;
	Integer topicCalculation;
	
	public Compatibility(String memberA, String memberB, int topicCalc) //constructor 
	{
		this.memberA = memberA;
		this.memberB = memberB;
		topicCalculation = topicCalc;
	}
	
	public String getMemberA() //getter for member a/1
	{
		return memberA;
	}
	public String getMemberB() //getter for member b/2
	{
		return memberB;
	}
	public void setMemberA(String mem)
	{
		memberA = mem;
	}
	public void setMemberB(String mem)
	{
		memberB = mem;
	}
	public int getTopicCalc() //getter for the topic's calculation
	{
		return topicCalculation;
	}
	public void setTopicCalc(int calc)
	{
		topicCalculation = calc;
	}
	public String toString()
	{
		String sentence = "Interest Score of " + memberA + " to " + memberB + ": "+ topicCalculation;
		
		return sentence;
	}

	public int compareTo(Compatibility compare) //compareTo method for when sorting the list via topic calc
	{
		return compare.getTopicCalc() - this.getTopicCalc();
	}
}
