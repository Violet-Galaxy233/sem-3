// Base class: GradedActivity
class GradedActivity {
    protected double score; // holds the numeric score

    // Set score
    public void setScore(double score) {
        this.score = score;
    }

    // Get score
    public double getScore() {
        return score;
    }

    // Determine grade based on score
    public char getGrade() {
        if (score >= 90)
            return 'A';
        else if (score >= 80)
            return 'B';
        else if (score >= 70)
            return 'C';
        else if (score >= 60)
            return 'D';
        else
            return 'F';
    }
}

// Subclass: Essay
class Essay extends GradedActivity {
    private double grammar; // 0–30
    private double spelling; // 0–20
    private double correctLength; // 0–20
    private double content; // 0–30

    // Constructor
    public Essay(double grammar, double spelling, double correctLength, double content) {
        this.grammar = grammar;
        this.spelling = spelling;
        this.correctLength = correctLength;
        this.content = content;

        // use super to update parent score
        double totalScore = grammar + spelling + correctLength + content;
        super.setScore(totalScore);
    }

    // Display breakdown and total
    public void displayEssayDetails() {
        System.out.println("Essay Score Details:");
        System.out.println("Grammar: " + this.grammar);
        System.out.println("Spelling: " + this.spelling);
        System.out.println("Correct Length: " + this.correctLength);
        System.out.println("Content: " + this.content);
        System.out.println("Total Score: " + super.getScore());
        System.out.println("Final Grade: " + super.getGrade());
    }
}

// Demo class
public class EssayTest {
    public static void main(String[] args) {
        // Example: Grammar 30, Spelling 20, Correct Length 12, Content 10 = total 72
        Essay essay1 = new Essay(30, 20, 12, 10);
        essay1.displayEssayDetails();
    }
}
