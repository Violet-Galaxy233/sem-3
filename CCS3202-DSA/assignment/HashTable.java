public class HashTable {
    private Integer[] table;
    private int m;

    public HashTable(int m) {
        this.m = m;
        this.table = new Integer[m];
    }

    private int hashFunc(int k) {
        // h1(k) = 2k mod m
        return (2 * k) % m;
    }

    public int insert(int k) {
        int h = hashFunc(k);
        int i = 0;
        while (i < m) {
            int pos = (h + i) % m;
            if (table[pos] == null) {
                table[pos] = k;
                return pos;
            }
            i++;
        }
        return -1; // Table is full
    }

    public int find(int k) {
        int h = hashFunc(k);
        int i = 0;
        while (i < m) {
            int pos = (h + i) % m;
            if (table[pos] != null && table[pos] == k) {
                return pos;
            }
            // If we encounter an empty slot, the item is not in the table
            if (table[pos] == null) {
                break;
            }
            i++;
        }
        return -1; // Item not found
    }

    public void printTable() {
        System.out.print("Final Table: [");
        for (int i = 0; i < m; i++) {
            if (table[i] == null) {
                System.out.print("None");
            } else {
                System.out.print(table[i]);
            }
            if (i < m - 1) {
                System.out.print(", ");
            }
        }
        System.out.println("]");
    }

    public static void main(String[] args) {
        // Task 2 Example Test
        int m2 = 9;
        int[] keys2 = {45, 23, 102, 96, 116, 87};
        HashTable ht = new HashTable(m2);
        System.out.println("\n--- Task 2: Program Simulation (Java) ---");
        for (int k : keys2) {
            int idx = ht.insert(k);
            System.out.println("Inserted " + k + " at " + idx);
        }
        ht.printTable();

        int target1 = 87;
        int idx1 = ht.find(target1);
        System.out.println("Find " + target1 + ": " + (idx1 != -1 ? "index " + idx1 : "item not found"));

        int target2 = 100;
        int idx2 = ht.find(target2);
        System.out.println("Find " + target2 + ": " + (idx2 != -1 ? "index " + idx2 : "item not found"));
    }
}