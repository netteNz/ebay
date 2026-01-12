import com.nettenz.ebay.util.PasswordUtil;

public class HashGen {
    public static void main(String[] args) {
        System.out.println("HASH_START");
        System.out.println(PasswordUtil.hash("password"));
        System.out.println("HASH_END");
    }
}
