import java.io.Serializable;
import java.util.*;

public abstract class ArrayList<T> implements ListADT<T>, Iterable<T>, Serializable
{
    private final static int DEFAULT_CAPACITY = 3;
    private final static int NOT_FOUND = -1;
	
    protected int rear;
    protected T[] list; 
	protected int modCount;

    public ArrayList()
    {
        this(DEFAULT_CAPACITY);
    }
    
    public ArrayList(int initialCapacity)
    {
        rear = 0;
        list = (T[])(new Object[initialCapacity]);
		modCount = 0;
    }

    protected void expandCapacity()
    {
    	@SuppressWarnings("unchecked")
		T[] newList = (T[])(new Object[list.length * 2]); //just doubles previous list.length
    	
    	for(int i = 0; i < list.length; i++) //copies old list into newList array
    	{
    		newList[i] = list[i]; 
    	}
    	list = newList;
    }
	
    public T removeLast() throws EmptyCollectionException
    {
    	if (isEmpty())
    	{
    		throw new EmptyCollectionException("Caught in removeLast()");
    	}
    	else
    	{
	    	T store;
	    
	        rear--; //decrement rear due to one less item in list
	        store = list[rear];//stores last element to return
	        list[rear] = null; //deletes the element
	        return store;
    	}
    }

    public T removeFirst() throws EmptyCollectionException
    {
    	if(isEmpty())
        {
        	throw new EmptyCollectionException("Caught in removeFirst()");
        }
        else
        {
        	T store;
        	rear--; //decrement rear due to one less item being in list
        	
        	store = list[0]; //stores first element (always in index 0)
        	
        	for(int i = 0; i < list.length; i++) //shifts the remaining elements over
        	{
        		list[i] = list[i + 1];
        	}
        	return store;
        }
    }

    public T remove(T removeMember)
    {
    	T result;
        int index = find(removeMember);

        if (index == NOT_FOUND)
        {
            throw new ElementNotFoundException("Caught in remove()");
        }
        
        result = list[index];
        rear--;
		
        // shift the appropriate elements 
        for (int scan=index; scan < rear; scan++)
            list[scan] = list[scan+1];
 
        list[rear] = null;
		modCount++;
		return result;
    }
   
    public T first() throws EmptyCollectionException
    {
    	if (isEmpty())
    	{
    		throw new EmptyCollectionException("Caught in first()");
    	}
    	else
    	{
    		return list[0]; //first item will always be in index 0, so return list[0]
    	}
    }

    public T last() throws EmptyCollectionException
    {
    	if(isEmpty())
    	{
    		throw new EmptyCollectionException("Caught in last()");
    	}
        return list[rear - 1]; //since rear points to next available spot
        					   //rear - 1 returns index of last filled spot 
    }

    public boolean contains(T target)
    {
        return (find(target) != NOT_FOUND);
    }

    private int find(T target)
    {
        int scan = 0; 
		int result = NOT_FOUND;
 
        if (!isEmpty())
            while (result == NOT_FOUND && scan < rear)
                if (target.equals(list[scan]))
                    result = scan;
                else
                    scan++;

        return result;
    }

    public boolean isEmpty()
    {
    	if (size() == 0) //if the size is 0 then it is empty
        {
        	return true;
        }
        else 
        {
        	return false;
        }
    }
 
    public int size()
    {
    	return rear; // returns next available empty index; if rear is 0 then list is empty
    }

    public String toString()
    {
    	 String actualWords = ""; //initialize string for time being
         
         for(int i = 0; i < rear; i++) //loop to append the contents of the array list into a string
         {
      	   actualWords = (actualWords + list[i].toString() + "\n");
         }
         
         return actualWords; //the spoken truth
    }
	
    public Iterator<T> iterator()
    {
        return new ArrayListIterator();
    }

	private class ArrayListIterator implements Iterator<T>
	{
		int iteratorModCount;
		int current;
		
		public ArrayListIterator()
		{
			iteratorModCount = modCount;
			current = 0;
		}
		
		public boolean hasNext() throws ConcurrentModificationException
		{
			if (iteratorModCount != modCount)
				throw new ConcurrentModificationException();
			
			return (current < rear);
		}
		
		public T next() throws ConcurrentModificationException
		{
			if (!hasNext())
				throw new NoSuchElementException();
			
			current++;
			
			return list[current - 1];
		}
		
		public void remove() throws UnsupportedOperationException
		{
			throw new UnsupportedOperationException();
		}
		
	}	
}
