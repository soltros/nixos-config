package dev.soltros.snake;
import java.util.*;

/** Android-independent, discrete grid simulation. */
public final class SnakeGame {
    public static final int SIZE = 18;
    public enum State { READY, PLAYING, PAUSED, OVER, WON }
    public final ArrayList<Integer> body = new ArrayList<>();
    public State state;
    public int direction, food, score;
    private final ArrayDeque<Integer> turns = new ArrayDeque<>();
    private final Random random;
    public SnakeGame(Random random) { this.random = random; reset(); }
    public void reset() {
        body.clear(); body.add(9*SIZE+8); body.add(9*SIZE+7); body.add(9*SIZE+6);
        direction=1; score=0; turns.clear(); state=State.READY; placeFood();
    }
    public void turn(int next) {
        if (state != State.PLAYING || turns.size() >= 2) return;
        int last = turns.isEmpty() ? direction : turns.peekLast();
        if (next >= 0 && next < 4 && next != last && (last+2)%4 != next) turns.add(next);
    }
    public int interval() { return Math.max(85, 185-score*3); }
    public void step() {
        if (state != State.PLAYING) return;
        if (!turns.isEmpty()) direction=turns.remove();
        int head=body.get(0), x=head%SIZE, y=head/SIZE;
        x += direction==1 ? 1 : direction==3 ? -1 : 0;
        y += direction==2 ? 1 : direction==0 ? -1 : 0;
        int next=y*SIZE+x;
        boolean eat=next==food;
        int occupied=body.size()-(eat?0:1);
        if (x<0 || x>=SIZE || y<0 || y>=SIZE || body.subList(0,occupied).contains(next)) { state=State.OVER; return; }
        body.add(0,next);
        if (eat) { score++; placeFood(); } else body.remove(body.size()-1);
    }
    private void placeFood() {
        if (body.size()==SIZE*SIZE) { food=-1; state=State.WON; return; }
        ArrayList<Integer> empty=new ArrayList<>();
        for(int i=0;i<SIZE*SIZE;i++) if(!body.contains(i)) empty.add(i);
        food=empty.get(random.nextInt(empty.size()));
    }
}
