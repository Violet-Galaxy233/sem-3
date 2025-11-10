// Base class: GradedActivity
class GradedActivity {
    protected double score;

    // Set score
    public void setScore(double score) {
        this.score = score;
    }

    // Get score
    public double getScore() {
        return score;
    }

    // Get grade based on score
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
    private double grammar;
    private double spelling;
    private double correctLength;
    private double content;

    // Overload setScore(): accept 4 parameters
    public void setScore(double grammar, double spelling, double correctLength, double content) {
        this.grammar = grammar;
        this.spelling = spelling;
        this.correctLength = correctLength;
        this.content = content;

        // Use super to update total score
        double totalScore = grammar + spelling + correctLength + content;
        super.setScore(totalScore);
    }

    // Override setScore(double): disallow single-parameter use
    @Override
    public void setScore(double score) {
        System.out.println(
                "⚠️ Error: Class Essay is not allowed to call setScore() with a single value (calling with parameter "
                        + score + ").");
    }

    // Override getGrade(): force F if any component is 0
    @Override
    public char getGrade() {
        if (grammar == 0 || spelling == 0 || correctLength == 0 || content == 0) {
            return 'F';
        } else {
            return super.getGrade();
        }
    }

    // Show breakdown
    public void showDetails() {
        System.out.println("\nEssay Score Breakdown:");
        System.out.println("Grammar: " + grammar);
        System.out.println("Spelling: " + spelling);
        System.out.println("Correct Length: " + correctLength);
        System.out.println("Content: " + content);
        System.out.println("Total Score: " + super.getScore());
        System.out.println("Final Grade: " + getGrade());
    }
}

// Demo class
public class EssayOverloadOverrideTest {
    public static void main(String[] args) {
        Essay essay = new Essay();

        // Case 1: valid input using 4 parameters
        essay.setScore(30, 20, 12, 10);
        essay.showDetails();

        // Case 2: invalid call with one parameter
        essay.setScore(-2);

        // Case 3: one part is 0 → should force F
        essay.setScore(30, 0, 20, 30);
        essay.showDetails();
    }
}
