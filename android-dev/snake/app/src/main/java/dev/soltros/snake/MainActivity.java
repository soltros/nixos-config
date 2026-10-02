package dev.soltros.snake;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.content.SharedPreferences;
import android.graphics.*;
import android.graphics.drawable.GradientDrawable;
import android.view.*;
import android.widget.*;
import java.util.Random;

public final class MainActivity extends Activity {
    private final int BG=Color.rgb(16,23,18), PANEL=Color.rgb(26,37,29), GREEN=Color.rgb(185,245,130), INK=Color.rgb(234,242,228), MUTED=Color.rgb(142,163,146);
    private final SnakeGame game=new SnakeGame(new Random());
    private final Handler handler=new Handler(Looper.getMainLooper());
    private SharedPreferences prefs;
    private int best;
    private TextView scoreLabel, bestLabel, hint;
    private Button action, pause;
    private Board board;
    private final Runnable tick=new Runnable() { public void run() {
        if(game.state!=SnakeGame.State.PLAYING) return;
        int previous=game.score; game.step();
        if(game.score>previous) board.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK);
        if(game.score>best) { best=game.score; prefs.edit().putInt("best",best).apply(); }
        update();
        if(game.state==SnakeGame.State.PLAYING) handler.postDelayed(this,game.interval());
    }};
    private int dp(float n) { return (int)(n*getResources().getDisplayMetrics().density+.5f); }
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setStatusBarColor(BG); getWindow().setNavigationBarColor(BG);
        prefs=getSharedPreferences("snake",MODE_PRIVATE); best=prefs.getInt("best",0);
        LinearLayout root=new LinearLayout(this); root.setOrientation(1); root.setBackgroundColor(BG);
        root.setPadding(dp(24),dp(12),dp(24),dp(16));
        root.setOnApplyWindowInsetsListener((v,insets)-> {
            android.graphics.Insets bars=insets.getInsets(WindowInsets.Type.systemBars());
            v.setPadding(dp(24)+bars.left,dp(12)+bars.top,dp(24)+bars.right,dp(16)+bars.bottom); return insets;
        });
        // Insets.Type is available on API 30+, while older devices use the fitting fallback.
        if(android.os.Build.VERSION.SDK_INT<30) { root.setOnApplyWindowInsetsListener(null); root.setFitsSystemWindows(true); }
        setContentView(root);
        TextView eyebrow=text("THE LITTLE ARCADE",11,MUTED); eyebrow.setLetterSpacing(.20f); root.addView(eyebrow);
        LinearLayout header=row(); TextView title=text("snake",44,INK); title.setTypeface(Typeface.create("sans-serif-medium",0));
        header.addView(title,new LinearLayout.LayoutParams(0,dp(64),1));
        pause=button("Pause",false); header.addView(pause,new LinearLayout.LayoutParams(dp(88),dp(48))); pause.setOnClickListener(v->togglePause()); root.addView(header);
        LinearLayout stats=row(); scoreLabel=text("",17,GREEN); bestLabel=text("",17,MUTED);
        stats.addView(scoreLabel,new LinearLayout.LayoutParams(0,dp(44),1)); stats.addView(bestLabel); root.addView(stats);
        board=new Board(); root.addView(board,new LinearLayout.LayoutParams(-1,0,1));
        hint=text("",13,MUTED); hint.setGravity(Gravity.CENTER); root.addView(hint,new LinearLayout.LayoutParams(-1,dp(38)));
        LinearLayout up=row(); up.setGravity(Gravity.CENTER); addDirection(up,"↑",0); root.addView(up);
        LinearLayout arrows=row(); arrows.setGravity(Gravity.CENTER); addDirection(arrows,"←",3); addDirection(arrows,"↓",2); addDirection(arrows,"→",1); root.addView(arrows);
        action=button("Let's play",true); LinearLayout.LayoutParams ap=new LinearLayout.LayoutParams(-1,dp(54)); ap.topMargin=dp(12); root.addView(action,ap);
        action.setOnClickListener(v->{
            if(game.state==SnakeGame.State.PLAYING) { togglePause(); return; }
            if(game.state==SnakeGame.State.OVER || game.state==SnakeGame.State.WON) game.reset();
            game.state=SnakeGame.State.PLAYING; startLoop();
        }); update();
    }
    private LinearLayout row() { LinearLayout l=new LinearLayout(this); l.setGravity(Gravity.CENTER_VERTICAL); return l; }
    private TextView text(String s,int size,int color) { TextView t=new TextView(this); t.setText(s); t.setTextSize(size); t.setTextColor(color); t.setGravity(Gravity.CENTER_VERTICAL); return t; }
    private Button button(String s,boolean primary) {
        Button b=new Button(this); b.setText(s); b.setTextSize(15); b.setAllCaps(false); b.setTextColor(primary?BG:INK);
        GradientDrawable shape=new GradientDrawable(); shape.setColor(primary?GREEN:PANEL); shape.setCornerRadius(dp(16));
        b.setBackground(new android.graphics.drawable.RippleDrawable(android.content.res.ColorStateList.valueOf(0x337F9F70),shape,null)); return b;
    }
    private void addDirection(LinearLayout row,String label,int direction) {
        Button b=button(label,false); b.setTextSize(25); b.setContentDescription(new String[]{"Move up","Move right","Move down","Move left"}[direction]);
        LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(dp(72),dp(48)); lp.setMargins(dp(4),dp(3),dp(4),dp(3)); row.addView(b,lp);
        b.setOnClickListener(v->game.turn(direction));
    }
    private void startLoop() { handler.removeCallbacks(tick); update(); handler.postDelayed(tick,game.interval()); }
    private void togglePause() {
        if(game.state==SnakeGame.State.PLAYING) { game.state=SnakeGame.State.PAUSED; handler.removeCallbacks(tick); update(); }
        else if(game.state==SnakeGame.State.PAUSED) { game.state=SnakeGame.State.PLAYING; startLoop(); }
    }
    private void update() {
        scoreLabel.setText(String.format(java.util.Locale.US,"SCORE  %02d",game.score)); bestLabel.setText(String.format(java.util.Locale.US,"BEST  %02d",best));
        boolean playing=game.state==SnakeGame.State.PLAYING;
        pause.setEnabled(playing||game.state==SnakeGame.State.PAUSED); pause.setAlpha(pause.isEnabled()?1f:.35f); pause.setText(game.state==SnakeGame.State.PAUSED?"Resume":"Pause");
        action.setText(playing?"Pause game":game.state==SnakeGame.State.PAUSED?"Keep going":game.state==SnakeGame.State.READY?"Let's play":"Play again");
        hint.setText(playing?"Swipe or use the arrows. Find your rhythm.":game.state==SnakeGame.State.OVER?"A fresh start is just a tap away.":"Eat the peach dots. Leave room to grow.");
        board.invalidate();
    }
    @Override protected void onPause() { super.onPause(); if(game.state==SnakeGame.State.PLAYING) game.state=SnakeGame.State.PAUSED; handler.removeCallbacks(tick); update(); }
    @Override protected void onDestroy() { handler.removeCallbacksAndMessages(null); super.onDestroy(); }
    @Override public boolean onKeyDown(int key, android.view.KeyEvent event) {
        int d=key==KeyEvent.KEYCODE_DPAD_UP||key==KeyEvent.KEYCODE_W?0:key==KeyEvent.KEYCODE_DPAD_RIGHT||key==KeyEvent.KEYCODE_D?1:key==KeyEvent.KEYCODE_DPAD_DOWN||key==KeyEvent.KEYCODE_S?2:key==KeyEvent.KEYCODE_DPAD_LEFT||key==KeyEvent.KEYCODE_A?3:-1;
        if(d>=0) { game.turn(d); return true; } if(key==KeyEvent.KEYCODE_SPACE) { action.performClick(); return true; } return super.onKeyDown(key,event);
    }
    final class Board extends View {
        final Paint paint=new Paint(3); float startX,startY;
        Board() { super(MainActivity.this); setContentDescription("Snake game board. Swipe to steer; arrow buttons are available below."); }
        void box(Canvas c,float l,float t,float r,float b,float radius,int color) { paint.setColor(color); c.drawRoundRect(l,t,r,b,radius,radius,paint); }
        @Override protected void onDraw(Canvas c) {
            float side=Math.min(getWidth(),getHeight()), left=(getWidth()-side)/2, top=(getHeight()-side)/2, unit=(side-dp(16))/SnakeGame.SIZE;
            box(c,left,top,left+side,top+side,dp(22),PANEL); float ox=left+dp(8),oy=top+dp(8);
            paint.setColor(0xFF334237);
            for(int y=0;y<SnakeGame.SIZE;y++) for(int x=0;x<SnakeGame.SIZE;x++) c.drawCircle(ox+(x+.5f)*unit,oy+(y+.5f)*unit,dp(.7f),paint);
            if(game.food>=0) { float x=ox+(game.food%18+.5f)*unit,y=oy+(game.food/18+.5f)*unit; paint.setColor(0x22EF9B79); c.drawCircle(x,y,unit*.65f,paint); paint.setColor(0xFFEF9B79); c.drawCircle(x,y,unit*.29f,paint); }
            for(int i=game.body.size()-1;i>=0;i--) {
                int pos=game.body.get(i); float x=ox+(pos%18)*unit,y=oy+(pos/18)*unit;
                box(c,x+1,y+1,x+unit-1,y+unit-1,unit*.27f,i==0?GREEN:0xFF82B861);
                if(i==0) {
                    float cx=x+unit*.5f,cy=y+unit*.5f,forward=unit*.19f,spread=unit*.18f;
                    int dx=game.direction==1?1:game.direction==3?-1:0,dy=game.direction==2?1:game.direction==0?-1:0;
                    paint.setColor(BG);
                    for(int sign:new int[]{-1,1}) c.drawCircle(cx+dx*forward+dy*spread*sign,cy+dy*forward+dx*spread*sign,unit*.065f,paint);
                }
            }
            if(game.state!=SnakeGame.State.PLAYING) {
                box(c,left,top,left+side,top+side,dp(22),0xCC101712);
                String title=game.state==SnakeGame.State.READY?"A little focus.":game.state==SnakeGame.State.PAUSED?"Take a breath.":game.state==SnakeGame.State.WON?"Beautifully done.":"One more round?";
                String subtitle=game.state==SnakeGame.State.READY?"A little fun.":game.state==SnakeGame.State.PAUSED?"Your snake can wait.":"You grew by "+game.score+". Keep growing.";
                paint.setTextAlign(Paint.Align.CENTER); paint.setTypeface(Typeface.create("sans-serif-medium",0)); paint.setTextSize(dp(25)); paint.setColor(INK); c.drawText(title,getWidth()/2f,getHeight()/2f-dp(5),paint);
                paint.setTypeface(Typeface.DEFAULT); paint.setTextSize(dp(14)); paint.setColor(MUTED); c.drawText(subtitle,getWidth()/2f,getHeight()/2f+dp(23),paint); paint.setTextAlign(Paint.Align.LEFT);
            }
        }
        @Override public boolean performClick() { super.performClick(); return true; }
        @Override public boolean onTouchEvent(MotionEvent e) {
            if(e.getAction()==MotionEvent.ACTION_DOWN) { startX=e.getX();startY=e.getY(); return true; }
            if(e.getAction()==MotionEvent.ACTION_MOVE) {
                float dx=e.getX()-startX,dy=e.getY()-startY;
                if(Math.max(Math.abs(dx),Math.abs(dy))>dp(22)) { game.turn(Math.abs(dx)>Math.abs(dy)?(dx>0?1:3):(dy>0?2:0)); startX=e.getX();startY=e.getY(); }
                return true;
            }
            if(e.getAction()==MotionEvent.ACTION_UP) { performClick();return true; } return true;
        }
    }
}
