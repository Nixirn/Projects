import java.io.Serializable;

public class ArrayUnorderedList<T> extends ArrayList<T> 
         implements UnorderedListADT<T>, Serializable
{
    public ArrayUnorderedList()
    {
        super();
    }

    public ArrayUnorderedList(int initialCapacity)
    {
        super(initialCapacity);
    }

    public void addToFront(T element)
    {
    	if(size() == list.length)
    	{
    		expandCapacity();
    	}
    
    	for (int i=0; i < rear; i++)
    	{
            list[i] = list[i+1];
    	}
    	list[0] = element;
    	rear++;
    	modCount++;
    	
    }

    public void addToRear(T element)
    {
    	if(size()==list.length)  		
		{
			expandCapacity();
		}
		list[rear] = element;
		rear++;
		modCount++;
    }

    public void addAfter(T element, T target)
    {
        if (size() == list.length)
            expandCapacity();

        int scan = 0;
		
		// find the insertion point
        while (scan < rear && !target.equals(list[scan])) 
            scan++;
      
        if (scan == rear)
            throw new ElementNotFoundException("UnorderedList");
    
        scan++;
		
		// shift elements up one
        for (int shift=rear; shift > scan; shift--)
            list[shift] = list[shift-1];

		// insert element
		list[scan] = element;
        rear++;
		modCount++;
    }
}
