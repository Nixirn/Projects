import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

public class MemberList<T> extends ArrayUnorderedList<T> implements Serializable
{	
	public MemberList<Member> load(String fileName) throws IOException, ClassNotFoundException
	{
		FileInputStream fis = new FileInputStream(fileName);
    	ObjectInputStream ois = new ObjectInputStream(fis);
    	@SuppressWarnings("unchecked")
		MemberList<Member> mL = (MemberList<Member>) ois.readObject();
    	ois.close();
    	
    	return mL;
    	
	}
	
	public void save(String fileName) throws IOException, ClassNotFoundException
	{
		FileOutputStream fos = new FileOutputStream(fileName);
    	ObjectOutputStream oos = new ObjectOutputStream(fos);
    	oos.writeObject(this);
    	oos.flush();
    	oos.close();

	}
}
