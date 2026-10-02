package dev.soltros.snake;
import java.util.*;
public final class SnakeGameTest {
    static void check(boolean b,String message) { if(!b) throw new AssertionError(message); }
    static SnakeGame playing() { SnakeGame g=new SnakeGame(new Random(7));g.state=SnakeGame.State.PLAYING;return g; }
    public static void main(String[] args) {
        SnakeGame g=playing(); int head=g.body.get(0); g.food=0; g.turn(3);g.step();check(g.body.get(0)==head+1,"reverse ignored");
        g=playing(); g.food=g.body.get(0)+1;g.step();check(g.score==1&&g.body.size()==4,"food grows snake");check(!g.body.contains(g.food),"food excludes snake");
        g=playing();g.food=0;g.turn(0);g.turn(3);g.step();check(g.direction==0,"first queued turn");g.step();check(g.direction==3,"second queued turn");
        g=playing();g.food=0;for(int i=0;i<20;i++)g.step();check(g.state==SnakeGame.State.OVER,"wall collision");
        g=playing();g.body.clear();g.body.addAll(Arrays.asList(19,20,38,37));g.direction=2;g.food=0;g.step();check(g.state==SnakeGame.State.PLAYING&&g.body.get(0)==37,"vacated tail is legal");
        g=playing();g.body.clear();g.body.addAll(Arrays.asList(19,20,38,37,55));g.direction=2;g.food=0;g.step();check(g.state==SnakeGame.State.OVER,"body collision");
        g=playing();g.state=SnakeGame.State.PAUSED;head=g.body.get(0);g.step();check(g.body.get(0)==head,"pause freezes simulation");
        g=playing();g.body.clear(); for(int i=0;i<324;i++)if(i!=1)g.body.add(i);g.direction=1;g.food=1;g.step();check(g.state==SnakeGame.State.WON&&g.food==-1,"full board wins");
        g.reset();check(g.state==SnakeGame.State.READY&&g.score==0&&g.body.size()==3,"restart clears game");
        System.out.println("Passed 11 Snake simulation checks.");
    }
}
