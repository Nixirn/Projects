import java.io.Serializable;

public class ArrayOrderedList<T> extends ArrayList<T>
         implements OrderedListADT<T>, Serializable
{
    public ArrayOrderedList()
    {
        super();
    }

    public ArrayOrderedList(int initialCapacity)
    {
        super(initialCapacity);
    }

    public void add(T element)
    {
		if (!(element instanceof Comparable))
			throw new NonComparableElementException("OrderedList");
		
		Comparable<T> comparableElement = (Comparable<T>)element;
        
		if (size() == list.length)
            expandCapacity();

        int scan = 0;  
		
		// find the insertion location
        while (scan < rear && comparableElement.compareTo(list[scan]) > 0)
            scan++;

		// shift existing elements up one
        for (int shift=rear; shift > scan; shift--)
            list[shift] = list[shift-1];

		// insert element
        list[scan] = element;
        rear++;
		modCount++;
    }
}
