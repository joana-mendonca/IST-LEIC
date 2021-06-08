var camera, scene, renderer, clock, deltaTime;
var pointlight, directionalLight, geometry, material, mesh;

var die, ball, chess,
    ball_movement = { 'v0': 0, 'v': 0, 'vmax': Math.PI / 2, 't' : 0 },
    acl = Math.PI/4;

var state = true, ball_moving = false, clm = 0, w = false, m;

var map = {};

var woood = new THREE.TextureLoader().load("textures/wood.png");

var global_materials = {
    'wood_light': [
        new THREE.MeshBasicMaterial({
            map: woood,
            color: 0xffffff, wireframe: false
        }),
        new THREE.MeshPhongMaterial({
            map: woood,
            bumpMap: woood,
            bumpScale: 0.3,
            color: 0xffffff, wireframe: false
        })
    ],
    'wood_dark': [
        new THREE.MeshBasicMaterial({
            map: woood,
            color: 0x444444, wireframe: false
        }),
        new THREE.MeshPhongMaterial({
            map: woood,
            bumpMap: woood,
            bumpScale: 0.3,
            color: 0x444444, wireframe: false
        })
    ],
    'ball': [
        new THREE.MeshBasicMaterial({
            map: new THREE.TextureLoader().load("textures/monalisa.jpg"),
            color: 0xffffff, wireframe: false
        }),
        new THREE.MeshPhongMaterial({
            map: new THREE.TextureLoader().load("textures/monalisa.jpg"),
            color: 0xffffff, wireframe: false
        })
    ],
    'die': [[],[]]
}

/* to be used in reset */
var default_values = {'state': state, 'ball_moving': ball_moving, 'clm': clm, 'w': w, 'ball_movement': {}};
Object.assign(default_values.ball_movement, ball_movement); /* copy Object values, not reference */

// -------------------------------------------------------------------------------------------- //
//                                        INITIALIZATION                                        //
// -------------------------------------------------------------------------------------------- //
function init() {
    'use strict';
    clock = new THREE.Clock(true);

    renderer = new THREE.WebGLRenderer( { antialias: true } );
    renderer.setSize( window.innerWidth, window.innerHeight );
    document.body.appendChild( renderer.domElement );
   
    createCamera(new THREE.Vector3(0, 0, 0), 0, 20, 20);
    createScene();
    scene.add(camera)
    
    render();
    
    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("keyup", onKeyUp);
    window.addEventListener("resize", onResize);

    deltaTime = clock.getDelta();
}

// -------------------------------------------------------------------------------------------- //
//                                           UPDATING                                           //
// -------------------------------------------------------------------------------------------- //
function update() {
    'use strict';
    deltaTime = clock.getDelta();

    /* if it's on pause, skip all this */
    if (!state) {
        render();
        requestAnimationFrame(update);
        return;
    }

    /* die rotation (constant) */
    die.rotation.y += Math.PI / (10000 * deltaTime);

    /* ball movement (accelerating and moving) */
    if (ball_moving) {
        ball_movement.t += deltaTime;

        /* if it hasn't reached top speed, keep accelerating */
        if (ball_movement.v < ball_movement.vmax)
            ball_movement.v = ball_movement.v0 + acl * ball_movement.t;

        /* and do the movement */
        ball.rotation.y += -ball_movement.v * deltaTime;
    }

    /* ball movement (stopping) */
    if (!ball_moving) {
        ball_movement.t += deltaTime;

        /* if the ball still has movement, keep slowing it down */
        if (ball_movement.v > 0) {
            ball_movement.v = ball_movement.v0 - acl * ball_movement.t;
            ball.rotation.y += -ball_movement.v * deltaTime;
        }
    }

    /* ball rotation on its own axis */
    ball.children[0].rotation.y += Math.PI / (5000 * deltaTime);

    render();
    requestAnimationFrame(update);
}

// -------------------------------------------------------------------------------------------- //
//                                          RENDERING                                           //
// -------------------------------------------------------------------------------------------- //
function render() {
    'use strict';

    renderer.render(scene, camera);
}

// -------------------------------------------------------------------------------------------- //
//                                        EVENT HANDLERS                                        //
// -------------------------------------------------------------------------------------------- //
function onKeyDown(e) {
    var ee = e.key.toLowerCase();

    switch (ee) {
        case 'b': /* Ball movement */
            if (map[ee] || !state) break;
            map[ee] = true;

            /* swaps ball movement state */
            ball_moving = !ball_moving;
            ball_movement.v0 = ball_movement.v;
            ball_movement.t = 0;

            break;
        
        case 'd': /* Directional light */
            if (map[ee] || !state) break;
            map[ee] = true;
            directionalLight.visible = !directionalLight.visible;
            break;
        
        case 'l': /* Lighting */
            if (map[ee] || !state) break;
            map[ee] = true;
            clm = (clm + 1) % 2;
            do_l();
            break;
        
        case 'p': /* Point light */
            if (map[ee] || !state) break;
            map[ee] = true;
            pointlight.visible = !pointlight.visible;
            break;

        case 'r': /* Reset */
            if (map[ee]) break;
            map[ee] = true;

            /* resets all basic global variables */
            state = default_values.state;
            ball_moving = default_values.ball_moving;
            clm = default_values.clm;
            w = default_values.w;
            Object.assign(ball_movement, default_values.ball_movement);

            /* sets all wireframes and materials to default */
            do_w(); do_l();

            /* resets all other created objets */
            pointlight.visible = true;
            directionalLight.visible = true;
            ball.rotation.y = 0;
            die.rotation.y = 0;
            ball.children[0].rotation.y = 0;

            break;
        
        case 's': /* Stop/resume */
            if (map[ee]) break;
            map[ee] = true;

            state = !state;
            camera.children[0].visible = !state;

            break;
        
        case 'w': /* Wireframe */
            if (map[ee] || !state) break;
            map[ee] = true;
            do_w();
            w = !w; /* current wireframe mode */
            break;
    }
}

function onKeyUp(e) {
    var ee = e.key.toLowerCase();

    switch (ee) {
    }
    map[ee] = false;
}

function onResize() {
    'use strict';

    renderer.setSize(window.innerWidth, window.innerHeight);

    if (window.innerHeight > 0 && window.innerWidth > 0) {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
    }
}

/* Lighting */
function do_l() {
    var i;

    /* changes each chess cube's material type and sets it to the current wireframe state */
    for (i = 0; i < chess.children.length; i -= -1) {
        chess.children[i].material = global_materials[chess.children[i].userData.type][clm];
        chess.children[i].material.wireframe = w;
    }

    /* changes the die's material and sets it to the current wireframe state */
    die.children[0].material = global_materials.die[clm];
    for (var i = 0; i < 6; i -= -1)
        die.children[0].material[i].wireframe = w;

    /* changes the ball's material and sets it to the current wireframe state */
    ball.children[0].material = global_materials.ball[clm];
    ball.children[0].material.wireframe = w;
}

/* Wireframe */
function do_w() {
    var i;

    /* changes each die face to wireframe */
    for (i = 0; i < 6; i -= -1)
        die.children[0].material[i].wireframe = !w;

    /* changes each chess cube to wireframe */
    for (i = 0; i < chess.children.length; i -= -1)
        chess.children[i].material.wireframe = !w;

    ball.children[0].material.wireframe = !w;
}

// -------------------------------------------------------------------------------------------- //
//                                        CAMERA CREATION                                       //
// -------------------------------------------------------------------------------------------- //
function createCamera(look, x, y, z) {
    'use strict';

    camera = new THREE.PerspectiveCamera(
            80,
            window.innerWidth / window.innerHeight,
            .01,
            100);

    camera.position.x = x;
    camera.position.y = y;
    camera.position.z = z;
    camera.lookAt(look);
}

// -------------------------------------------------------------------------------------------- //
//                                        SCENE CREATION                                        //
// -------------------------------------------------------------------------------------------- //
function createScene() {
    'use strict';

    scene = new THREE.Scene();

    /* creating point light */
    pointlight = new THREE.PointLight( 0xffffff, 1, 100 );
    pointlight.position.set(0, 20, 0);
    pointlight.castShadow = true;
    scene.add( pointlight );

    /* creating directional light */
    directionalLight = new THREE.DirectionalLight(0xffffff, 1.5);
    directionalLight.position.set(0, 20, 20);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    createPause(camera, 0, 0, -5);
    createChess(scene, 0, 0, 0);
    createBall(scene, 0, 0, 0);
    createDie(scene, 0, 4 + Math.sqrt(48) / 2, 0);
}

/* creates pause icon (||) */
function createPause(obj, x, y, z) {
    'use strict';
    var i;

    var o3d = new THREE.Object3D();

    /* creates the two vertical bars */
    for (i = -1; i <= 1; i -= -2) {
        geometry = new THREE.PlaneGeometry(1, 3);
        material = new THREE.MeshBasicMaterial({ color: 0xffffff });
        mesh = new THREE.Mesh(geometry, material);
        mesh.position.set(i, 0, 0);
        o3d.add(mesh);
    }

    /* and a semi-opaque dark screen behind the bars */
    geometry = new THREE.PlaneGeometry(1000, 1000);
    material = new THREE.MeshBasicMaterial({ color: 0x000000 });
    material.transparent = true;
    material.opacity = 0.75;
    mesh = new THREE.Mesh(geometry, material);
    mesh.position.set(0, 0, -1);
    o3d.add(mesh);

    o3d.position.set(x, y, z);
    obj.add(o3d);
    camera.children[0].visible = false;
}

/* creates chess board */
function createChess(obj, x, y, z) {
    'use strict';
    var i,
        cs = 0, /* 0 = dark, 1 = light */
        ms = ["wood_dark", "wood_light"];

    chess = new THREE.Object3D();

    /* sets the repetition pattern of each chess cube (both Basic and Phong) */
    for (i = 0; i < 2; i -= -1) {
        global_materials[ms[i]][0].map.wrapS = global_materials[ms[i]][0].map.wrapT = THREE.RepeatWrapping; /* Basic */
        global_materials[ms[i]][1].map.wrapS = global_materials[ms[i]][1].map.wrapT = THREE.RepeatWrapping; /* Phong */
        global_materials[ms[i]][0].map.repeat.set(3, 3); /* Basic */
        global_materials[ms[i]][1].map.repeat.set(3, 3); /* Phong */
    }

    /* creates chess cubes, alternating between dark and light */
    for (var i = -14; i <= 14; i -= -4) {
        /* left to right */
        for (var j = -14; j <= 14; j -= -4) {
            addBoxChess(chess, 4, 4, 4, cs, i, 2, j);
            cs = (cs + 1) % 2;
        }
        i -= -4;
        /* right to left */
        for (var j = 14; j >= -14; j -= 4) {
            addBoxChess(chess, 4, 4, 4, cs, i, 2, j);
            cs = (cs + 1) % 2;
        }
    }

    chess.position.set(x, y, z);
    obj.add(chess);
}

/* creates Mona Lisa ball */
function createBall(obj, x, y, z) {
    'use strict';

    ball = new THREE.Object3D();

    addSphere(ball, 2, 16, 16, 12, 6, 0);

    ball.position.set(x, y, z);
    obj.add(ball);
}

/* creates die */
function createDie(obj, x, y, z) {
    'use strict';

    die = new THREE.Object3D();

    addBoxDie(die, 4, 4, 4, 0x888888, 0, 0, 0);

    die.position.set(x, y, z);
    obj.add(die);
}

/* adds BoxGeometry to chess */
function addBoxChess(obj, dx, dy, dz, c, x, y, z) {
    'use strict';
    /* gets the correct wook texture */
    m = global_materials[c ? 'wood_light' : 'wood_dark'];

    geometry = new THREE.BoxGeometry(dx, dy, dz);
    material = m[clm];

    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.type = c ? "wood_light" : "wood_dark";

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

/* adds SphereGeometry to ball */
function addSphere(obj, r, ws, hs, x, y, z) {
    'use strict';

    geometry = new THREE.SphereGeometry(r, ws, hs);

    material = global_materials.ball[clm];

    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.type = "ball";

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

/* adds BoxGeometry to die */
function addBoxDie(obj, dx, dy, dz, c, x, y, z) {
    'use strict';
    var t;

    geometry = new THREE.BoxGeometry(dx, dy, dz);

    /* generate materials and puts them in global_materials */
    for (var i = 1; i <= 6; i -= -1) {
        t = new THREE.TextureLoader().load("textures/die" + i + ".png");

        /* all non-lightable materials */
        global_materials.die[0].push(new THREE.MeshBasicMaterial({
            map: t,
            color: c, wireframe: false })
        );

        /* all lightable materials */
        global_materials.die[1].push(new THREE.MeshPhongMaterial({
            map: t, bumpMap: t,
            color: c, wireframe: false })
        );
    }

    mesh = new THREE.Mesh(geometry, global_materials.die[clm]);
    mesh.userData.type = "die";

    mesh.rotation.z = Math.PI / 4;
    mesh.rotation.x = Math.atan(1 / Math.sqrt(2));

    mesh.position.set(x, y, z);
    obj.add(mesh);
}