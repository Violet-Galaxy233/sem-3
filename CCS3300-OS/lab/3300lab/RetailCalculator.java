import java.util.Scanner;

public class RetailCalculator {

    // Method to read product number
    public static int readProductNumber(Scanner input) {
        System.out.print("Enter product number (1-5, or -9999 to stop): ");
        return input.nextInt();
    }

    // Method to determine price based on product number
    public static double getProductPrice(int productNumber) {
        switch (productNumber) {
            case 1:
                return 2.98;
            case 2:
                return 4.50;
            case 3:
                return 9.98;
            case 4:
                return 4.49;
            case 5:
                return 6.87;
            default:
                System.out.println("Invalid product number!");
                return 0.0;
        }
    }

    // Method to read quantity sold
    public static int readQuantity(Scanner input) {
        System.out.print("Enter quantity sold: ");
        return input.nextInt();
    }

    // Method to calculate total for this product
    public static double calculateTotal(double price, int quantity) {
        return price * quantity;
    }

    // Method to display total retail value
    public static void displayTotal(double total) {
        System.out.printf("Total retail value of all products: RM%.2f\n", total);
    }

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        double grandTotal = 0.0;
        int productNumber;

        // Sentinel-controlled loop
        while (true) {
            productNumber = readProductNumber(input);
            if (productNumber == -9999)
                break;

            double price = getProductPrice(productNumber);
            if (price == 0)
                continue; // skip invalid product

            int quantity = readQuantity(input);
            double total = calculateTotal(price, quantity);
            grandTotal += total;

            System.out.printf("Product %d: RM%.2f x %d = RM%.2f\n",
                    productNumber, price, quantity, total);
        }

        // Display final result
        displayTotal(grandTotal);
        input.close();
    }
}
