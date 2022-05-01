import java.io.Serializable;

public class CompatibilityList<T> extends ArrayOrderedList<T> implements Serializable
{
    public String topMatches(int a, int b)
    {
    	//a is equal to match number 5 
    	//b is equal to top match
    	
    	String sentence = "";
    	
    	if (a < 0 || a > b || b > rear)
    	{
    		throw new IndexOutOfBoundsException("An error occurred retrieving top five matches");
    	}
    	else
    	{
    		for(int i = a - 1; i < b - 1; i++)
    		{	
    			sentence += sentence + list[i].toString() + "\n";
    		}
    	}
		return sentence;
    	
    }
}
