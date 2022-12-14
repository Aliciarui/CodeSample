// ******************************
// Code Sample(Javascript)
// Seal Cutting Display System
// JQuery Matter.js Paper.js
// 2022.6
// ******************************

function id2url_unlocked(id1=13){
    let tempname=fix(id1,2);
    let url=srcurl4+tempname+'.png';
    return url;
}

class initWorld{
    constructor() {
        this.time=0;
        this.h = window.innerHeight;
        this.w = screen.width;

        this.detectground = Bodies.rectangle(0,0,2*this.w,10,{isStatic:true,wall:true,
            collisionFilter:{
                category:tosensor,
                mask:tosensor
            }});

        this.initPaper();
        this.initMatter();
        this.addWall();
        this.mouseEvent();

        // this.calculateAngle();
        // this.renderLoop();
    }

    initMatter(){
        this.engine = Engine.create();
        this.engine.gravity.y=-0.01;
        this.render = Render.create({
            element:document.querySelector('#container'),
            engine:this.engine,
            options:{
                width:screen.width,
                height:screen.height,
                wireframes:true,
                showIds:true,
            }
        });
        Engine.run(this.engine);
        Render.run(this.render);
    }
    initPaper(){
        this.paperCanvas = document.getElementById('paper');
        this.project = new Paper.Project(this.paperCanvas);
    }
    addWall(){
        this.ground = Bodies.rectangle(0,-40,2*this.w,60,{isStatic:true,wall:true,
            collisionFilter:{
                category:tocollide,
                mask:tocollide | tosensor
            }});
        this.ground2 = Bodies.rectangle(-10,this.h,20,2*this.h,{isStatic:true,wall:true,
            collisionFilter:{
                category:tocollide,
                mask:tocollide | tosensor
            }});
        this.ground3 = Bodies.rectangle(this.w+10,this.h,20,2*this.h,{isStatic:true,wall:true,
            collisionFilter:{
                category:tocollide,
                mask:tocollide | tosensor
            }});
        World.add(this.engine.world,[this.ground,this.ground2,this.ground3]);

    }

    mouseEvent(){
        this.mouse = Mouse.create(this.render.canvas);
        this.mouseConstraint = MouseConstraint.create(this.engine,{
            mouse:this.mouse,
            constraint:{
                render:{visible:false}
            }
        });
        this.render.mouse=this.mouse;
        World.add(this.engine.world,[this.mouseConstraint]);
    }
    calculateAngle(){
        let diff_y=this.circles[1].position.y-this.circles[3].position.y;
        let diff_x=this.circles[1].position.x-this.circles[3].position.x;
        this.preangle=Math.atan(diff_y/diff_x);
    }
    renderLoop(){
        // this.time+=0.05;

        this.paperpath.smooth();
        for(let i=0;i<this.number;i++){
            this.paperpath.segments[i].point.x=this.circles[i].position.x;
            this.paperpath.segments[i].point.y=this.circles[i].position.y;
        }

        this.rasterImg.position.x=this.center.position.x;
        this.rasterImg.position.y=this.center.position.y;

        this.rasterImg.rotate((this.nowangle-this.preangle)*100);
        this.preangle=this.nowangle;
        // console.log(this.preangle);
        window.requestAnimationFrame(this.renderLoop.bind(this));
    }
}

class Bubbles{
    constructor() {
        this.rasterImg = [];
        this.shadow=[];
        this.paperPath = [];
        this.number = [];
        this.group = [];

        this.circles = [];
        this.links = [];
        this.center = [];
        this.scircle=[];

        this.num=0;
        this.nextnum=0;
        this.isadded=[[],[],[],[],[]];
        this.mylevel=[];
        this.clock=[];
    }
    addBubbles(path,level,mypicurl,sz){
        let tempnum=this.nextnum;
        this.clock.push(0);
        this.paperPath.push(new Paper.Path(path));
        this.shadow.push(new Paper.Path(path));

        this.number.push(this.paperPath[tempnum].segments.length);

        this.shadow[tempnum].fillColor='#ffffff';
        this.shadow[tempnum].shadowColor='#ffffff';
        this.shadow[tempnum].shadowBlur=30;


        this.center.push(Bodies.circle(
            (this.paperPath[tempnum].segments[0].point.x +
                this.paperPath[tempnum].segments[2].point.x)/2,
            (this.paperPath[tempnum].segments[0].point.y +
                this.paperPath[tempnum].segments[2].point.y)/2,
            sz+1,{
                isStatic:false,
                isCenter:true,
                centerNum:tempnum,
                level:level,
                collideWall:false,
                id1:13,
                id2:13,
                id3:13,
                id4:13,
                collisionFilter:{
                    category:tocollide,
                    mask:tocollide
                }
            }));

        this.scircle.push(Bodies.circle(
            (this.paperPath[tempnum].segments[0].point.x +
                this.paperPath[tempnum].segments[2].point.x)/2,
            (this.paperPath[tempnum].segments[0].point.y +
                this.paperPath[tempnum].segments[2].point.y)/2,
            sz+30,{
                isStatic:false,
                isSensor:true,
                centerNum:tempnum,
                collisionFilter:{
                    category:tosensor
                },
                density:0.004
            }));

        console.log(this.scircle[0].density);

        this.group.push(new Paper.Group([this.paperPath[tempnum]]));
        this.group[tempnum].clipped=true;

        this.rasterImg.push(new Paper.Raster({
            source:mypicurl,
            position:Paper.view.center,
        }))
        this.rasterImg[tempnum].scale(0.5);
        this.group[tempnum].addChild(this.rasterImg[tempnum])

        this.rasterImg[tempnum].opacity=1;

        let tempcircles=[];
        let templink=[];
        for(let i=0;i<this.number[tempnum];i++){
            tempcircles.push(
                Bodies.circle(
                    this.paperPath[tempnum].segments[i].point.x,
                    this.paperPath[tempnum].segments[i].point.y,
                    // this.shadow[tempnum].segments[i].point.x,
                    // this.shadow[tempnum].segments[i].point.y,
                    1,{
                        density:0.005,
                        restitution:0,
                        isSensor:false,
                        isCenter:false,
                        isStatic:false,
                        collisionFilter:{
                            category:defaultc
                        }
                    }
                )
            )
        }
        this.circles.push(tempcircles);


        for(let i =0;i<this.number[tempnum];i++){
            let next = this.circles[tempnum][i+1]?this.circles[tempnum][i+1]:this.circles[tempnum][0];
            templink.push(
                Constraint.create({
                    bodyA:this.circles[tempnum][i],
                    bodyB:next,
                    stiffness:1
                }),
                Constraint.create({
                    bodyA:this.circles[tempnum][i],
                    bodyB:this.center[tempnum],
                    stiffness:1
                }),
                Constraint.create({
                    bodyA:this.center[tempnum],
                    bodyB:this.scircle[tempnum],
                    stiffness:1
                })
            )
        }

        templink.push(
            Constraint.create({
                bodyA:this.circles[tempnum][0],
                bodyB:this.circles[tempnum][2],
                stiffness:1
            }),
            Constraint.create({
                bodyA:this.circles[tempnum][1],
                bodyB:this.circles[tempnum][3],
                stiffness:1
            }),

        )

        this.links.push(templink);
        this.movePic();
        this.nextnum++;
        this.num++;
    }
    size(level,num){
        this.mylevel[num]=level;
        // return 25+30*(level-1)+Math.floor(Math.random()*10);
        if(level==1) return 35+Math.floor(Math.random()*7);
        else if(level==2) return 51+Math.floor(Math.random()*9);
        else if(level==3) return 68+Math.floor(Math.random()*8);
        else if(level==4) return 84+Math.floor(Math.random()*8);
        //35----42(45-----55)
        //51----60(65-----75)
        //68----76(85-----95)
        //84----92(105---115)
    }
    ellipse2path(cx, cy, rx, ry) {
        if (isNaN(cx - cy + rx - ry))
            return;
        let path =
            'M' + (cx-rx) + ' ' + cy +
            'a' + rx + ' ' + ry + ' 0 1 0 ' + 2*rx + ' 0' +
            'a' + rx + ' ' + ry + ' 0 1 0 ' + (-2*rx) + ' 0' +
            'z';
        return path;
    }
    movePic(){
        for(let j=0;j<this.num;j++){
            this.paperPath[j].smooth();
            this.shadow[j].smooth();
            for(let i=0;i<this.number[j];i++){
                this.shadow[j].segments[i].point.x=this.circles[j][i].position.x;
                this.shadow[j].segments[i].point.y=this.circles[j][i].position.y;
                this.paperPath[j].segments[i].point.x=this.circles[j][i].position.x;
                this.paperPath[j].segments[i].point.y=this.circles[j][i].position.y;
            }

            this.rasterImg[j].position.x=this.center[j].position.x;
            this.rasterImg[j].position.y=this.center[j].position.y;
        }
        window.requestAnimationFrame(this.movePic.bind(this));
    }
}
let ini = new initWorld();
let newb = new Bubbles();
let piccount=0;

function showPic(bubble,num){
    bubble.rasterImg[num].opacity+=0.1;

    let timeout1=window.setTimeout(function()
    {
        //add condition and cleartimeout
        window.clearTimeout(timeout1);
        if(bubble.rasterImg[num].opacity<1){
            showPic(bubble,num);
        }
    }, 50);
    piccount++;
    if(bubble.rasterImg[num].opacity>=1){
        clearTimeout(timeout1);
        bubble.rasterImg[num].opacity=1;
    }
};

