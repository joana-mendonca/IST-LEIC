var geometry, material, mesh, map = {};

var cameras = [],
    camera_active = 0,
    scene, renderer, clock, deltaTime, t;

var cannons = [],
    balls = [],
    bboxes = [],
    ball_radius = 4,
    ball_mass = 0.2,
    a_cof = -15,
    at = true,
    cannon_active = 0,
    aux_v_x = new THREE.Vector3(1, 0, 0); /* vector spanning the colliding balls' centres */

// -------------------------------------------------------------------------------------------- //
//                                        INITIALIZATION                                        //
// -------------------------------------------------------------------------------------------- //
function init() {
    'use strict';

    renderer = new THREE.WebGLRenderer({ antialias: true });
    clock = new THREE.Clock(true);

    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);
   
    createScene();
    createCamera(0, 0, {'x': -60, 'y': 0, 'z': 0}, -60, 50, 0);
    createCamera(1, 1, {'x': -60, 'y': 0, 'z': 0}, -60, 160, 100);
    createCamera(2, 1, scene.position, 0, 0, 100);
    
    render();
    
    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("keyup", onKeyUp);
    window.addEventListener("resize", onResize);
}

// -------------------------------------------------------------------------------------------- //
//                                           UPDATING                                           //
// -------------------------------------------------------------------------------------------- //
function update() {
    'use strict';

    var g, b,       /* grey and brown */
        i, j,       /* iterators */
        p1, p2,     /* ball centres */
        theta,      /* angle between x axis and aux_v_x */
        b, c;       /* used for splicing 'balls' array */

    deltaTime = clock.getDelta();

    // change active cannon's color
    for (i = 0; i < cannons.length; i -= -1) {
        g = 0x7d7d7d; b = 0x8a3a08;

        if (i == cannon_active) { g = 0xe0e0e0; b = 0xbf6a34; }

        cannons[i].children[0].material.color.setHex(g);
        cannons[i].children[1].material.color.setHex(g);
        cannons[i].children[2].material.color.setHex(b);
        cannons[i].children[3].material.color.setHex(b);
        cannons[i].children[4].material.color.setHex(b);
    }

    // rotate active cannon
    if (map['ArrowLeft'] && !map['ArrowRight']) cannons[cannon_active].rotation.y += Math.PI / (5000 * deltaTime);
    if (map['ArrowRight'] && !map['ArrowLeft']) cannons[cannon_active].rotation.y += -Math.PI / (5000 * deltaTime);

    // calculate ball movement
    for (i = 0; i < balls.length; i -= -1) {
        if (balls[i].v == 0) continue;

        balls[i].t += deltaTime; 
        balls[i].ball.translateX(balls[i].v * deltaTime); /* translates the ball on its x axis */
        balls[i].bb.set(balls[i].ball.position, ball_radius); /* recalculates the ball's bounding sphere */

        /* boundaries */
        if (balls[i].ball.position.x < -182 || balls[i].ball.position.x > 70 || balls[i].ball.position.z < -64 || balls[i].ball.position.z > 64) {
            scene.remove(balls[i].ball);

            b = balls.splice(0, i);
            c = balls.splice(1);
            balls = b.concat(c);

            continue;
        }

        /* detect wall collision */
        for (j = 0; j < bboxes.length; j -= -1) {
            if (bboxes[j].bb.intersectsSphere(balls[i].bb)) {
                /* takes the ball out of the wall */
                balls[i].ball.translateX(-balls[i].v * deltaTime); 

                /* rotates it to the correct bouncing angle */
                balls[i].ball.rotation.y = (-balls[i].ball.rotation.y + 2 * bboxes[j].wall.rotation.y) % (2 * Math.PI);
            }
        }

        /* calculates new ball velocity */
        balls[i].v = balls[i].v0 + a_cof * balls[i].t;

        /* ball on ball collision detection */
        for (j = 0; j < balls.length; j -= -1) {
            if (i == j) continue;
            
            /* p1 = moving ball; p2 = collided ball */
            p1 = {'x': balls[i].ball.position.x, 'y': 0, 'z': balls[i].ball.position.z};
            p2 = {'x': balls[j].ball.position.x, 'y': 0, 'z': balls[j].ball.position.z};

            if (detectSphereSphereCollision(p1, p2)) {
                /* takes the ball out of the othe ball */
                balls[i].ball.translateX(-balls[i].v * deltaTime);

                /* calculates angle of the vector spanning both balls' centres compared to the x axis */
                theta = new THREE.Vector3().subVectors(p2, p1).angleTo(aux_v_x) * ((p1.z > p2.z) ? 1 : -1);

                balls[j].ball.rotation.y = theta;

                /* transfers the moving ball's motion to the other one */
                balls[j].v0 = balls[i].v0;
                balls[j].v = balls[i].v;
                balls[j].t = balls[i].t;

                balls[i].v = 0;
            }
        }

        /* rotates ball in its z axis (imitate rolling effect) */
        balls[i].ball.children[0].rotateZ(-(balls[i].v * deltaTime) / ball_radius); /*  */

        if (balls[i].v < 0) balls[i].v = 0; /* avoids negative speed values */
    }

    render();

    requestAnimationFrame(update);
}

// -------------------------------------------------------------------------------------------- //
//                                          RENDERING                                           //
// -------------------------------------------------------------------------------------------- //
function render() {
    'use strict';

    renderer.render(scene, cameras[camera_active]);
}

// -------------------------------------------------------------------------------------------- //
//                                        EVENT HANDLERS                                        //
// -------------------------------------------------------------------------------------------- //
function onKeyDown(e) {
    var ee = e.key;

    switch (ee) {
        case '1':
            camera_active = 0;
            break;
        case '2':
            camera_active = 1;
            break;
        case '3':
            camera_active = 2;
            break;
        case 'q':
        case 'Q':
            cannon_active = 0;
            break;
        case 'w':
        case 'W':
            cannon_active = 1;
            break;
        case 'e':
        case 'E':
            cannon_active = 2;
            break;
        case 'r':
        case 'R':
            toggleAxisHelper();
            break;
        case ' ':
            if (!map[ee]) shoot();
            map[ee] = true;
            break;
        case 'ArrowLeft':
        case 'ArrowRight':
            map[ee] = true;
            break;
    }
}

function onKeyUp(e) {
    var ee = e.key;

    switch (ee) {
        case ' ':
        case 'ArrowLeft':
        case 'ArrowRight':
            map[ee] = false;
            break;
    }
}

function toggleAxisHelper() {
    for (var i = 0; i < balls.length; i -= -1) {
        if (at) balls[i].ball.children[0].children.splice(0);
        else balls[i].ball.children[0].add(new THREE.AxisHelper(6));
    }
    at = !at;
}

function shoot() {
    'use strict';
    var vl = Math.random() * (100 - 80) + 80;

    var sph = addSphere(cannons[cannon_active], ball_radius, 10, 10, [0, Math.PI, 0], -21, ball_radius, 0);

    balls.push({
        'ball': sph,
        'bb': new THREE.Sphere(sph.getWorldPosition(), ball_radius),
        'v0': vl,
        'v': vl,
        't' : 0
    });

    cameras[2].parent = balls[balls.length - 1].ball;
    cameras[2].position.set(-20, 10, 0);
    cameras[2].lookAt(new THREE.Vector3(0, 0, 0));
}

function onResize() {
    'use strict';

    renderer.setSize(window.innerWidth, window.innerHeight);

    cameras[0].left = -window.innerWidth / 8;
    cameras[0].right = window.innerWidth / 8;
    cameras[0].top = window.innerHeight / 8;
    cameras[0].bottom = -window.innerHeight / 8;
    cameras[0].updateProjectionMatrix();

    for (var i = 1; i < cameras.length; i -= -1) {
        if (window.innerHeight > 0 && window.innerWidth > 0) {
            cameras[i].aspect = window.innerWidth / window.innerHeight;
            cameras[i].updateProjectionMatrix();
        }
    }
}

// -------------------------------------------------------------------------------------------- //
//                                        CAMERA CREATION                                       //
// -------------------------------------------------------------------------------------------- //
function createCamera(no, type, look, x, y, z) {
    //0 = orthographic, 1 = perspective
    'use strict';

    if (!type) {
        cameras[no] = new THREE.OrthographicCamera(
            window.innerWidth/-8, window.innerWidth/8,
            window.innerHeight/8, window.innerHeight/-8,
            1,
            1000);
    }
    else {
        cameras[no] = new THREE.PerspectiveCamera(
            80,
            window.innerWidth / window.innerHeight,
            1,
            1000);
    }

    cameras[no].position.x = x;
    cameras[no].position.y = y;
    cameras[no].position.z = z;
    cameras[no].lookAt(look);

    scene.add(cameras[no]);
}

// -------------------------------------------------------------------------------------------- //
//                                        SCENE CREATION                                        //
// -------------------------------------------------------------------------------------------- //
function createScene() {
    'use strict';
    var n, nx, nz, i;
    
    scene = new THREE.Scene();

    cannons[0] = createCannon(scene, -Math.PI / 12, 60, 0, 60);
    cannons[1] = createCannon(scene, 0, 60, 0, 0);
    cannons[2] = createCannon(scene, Math.PI / 12, 60, 0, -60);

    createWalls(scene, -120, 0, 0);
    createBalls(scene);
    
    scene.add(new THREE.AxisHelper(10));
}

function createBalls(obj) {
    'use strict';
    var n, nx, nz, i, sph;

    for (n = getRandomArbitrary(1, 10); n > 0; n += -1) {
        t = true;

        while (t) {
            nx = getRandomArbitrary(-180 + ball_radius + 2, -60 - ball_radius - 2);
            nz = getRandomArbitrary(-60 + ball_radius + 2, 60 - ball_radius - 2);

            if (balls.length == 0) break;
            
            t = false;

            for (i = 0; i < balls.length; i -= -1) {
                if (detectSphereSphereCollision({'x': balls[i].ball.position.x, 'z': balls[i].ball.position.z}, {'x': nx, 'z': nz})) {
                    t = true;
                    break;
                }
            }
        }

        sph = addSphere(obj, ball_radius, 10, 10, [0, 0, 0], nx, ball_radius, nz);

        balls.push({
            'ball': sph,
            'bb': new THREE.Sphere(sph.getWorldPosition(), ball_radius),
            'v0': 0,
            'v': 0,
            't' : 0
        });
    }
}

function createCannon(obj, rot, x, y, z) {
    'use strict';

    var cannon = new THREE.Object3D();

    addCylinder(cannon, 4, 4, 30, 20, [0, 0, Math.PI / 2], 0x7d7d7d, -10, 4, 0);
    addSemiSphere(cannon, 0x7d7d7d, 5, 4, 0);
    addCylinder(cannon, 1, 1, 10, 15, [Math.PI / 2, 0, 0], 0x8a3a08, 3, 3, 0);
    addCylinder(cannon, 3, 3, 1, 30, [Math.PI / 2, 0, 0], 0x8a3a08, 3, 3, 5);
    addCylinder(cannon, 3, 3, 1, 30, [Math.PI / 2, 0, 0], 0x8a3a08, 3, 3, -5);

    cannon.position.set(x, y, z);
    cannon.rotation.y = rot;
    obj.add(cannon);

    return cannon;
}

function createWalls(obj, x, y, z) {
    'use strict';

    addBox(obj, 120, 2 * ball_radius, 4, 0, -120, 5, -60);
    addBox(obj, 120, 2 * ball_radius, 4, 0, -120, 5, 60);
    addBox(obj, 124, 2 * ball_radius, 4, 1, -182, 5, 0);
}

// geometry creation functions
function addBox(obj, dx, dy, dz, r, x, y, z) {
    'use strict';

    geometry = new THREE.BoxGeometry(dx, dy, dz);
    material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);

    if (r) mesh.rotateY(Math.PI / 2)

    bboxes[bboxes.length] = {'wall': mesh, 'bb': new THREE.Box3().setFromObject(mesh)};

    obj.add(mesh);
}

function addSphere(obj, r, ws, hs, rot, x, y, z) {
    'use strict';

    var ball = new THREE.Object3D();

    geometry = new THREE.SphereGeometry(r, ws, hs);
    material = new THREE.MeshBasicMaterial({ color: 0xff00ff });
    mesh = new THREE.Mesh(geometry, material);

    ball.position.set(x, y, z);
    ball.rotation.x = rot[0];
    ball.rotation.y = rot[1];
    ball.rotation.z = rot[2];

    ball.add(mesh);
    mesh.add(new THREE.AxisHelper(6));
    obj.add(ball);

    /* converts position/rotation to univeral values and send ball to scene */
    var wp = ball.getWorldPosition();

    ball.position.set(wp.x, wp.y, wp.z);
    ball.rotation.y = obj.rotation.y + Math.PI;

    obj.remove(ball);
    scene.add(ball);

    return ball;
}

function addSemiSphere(obj, col, x, y, z) {
    'use strict';

    geometry = new THREE.SphereGeometry(4, 10, 10, Math.PI / 2, Math.PI, 0, Math.PI);
    material = new THREE.MeshBasicMaterial({ color: col });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addCylinder(obj, rt, rb, len, rs, rot, col, x, y, z) {
    'use strict';

    geometry = new THREE.CylinderGeometry(rt, rb, len, rs);
    material = new THREE.MeshBasicMaterial({ color: col });
    mesh = new THREE.Mesh(geometry, material);

    mesh.rotation.x = rot[0];
    mesh.rotation.y = rot[1];
    mesh.rotation.z = rot[2];
    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addRing(obj, ir, or, ts, x, y, z) {
    'use strict';

    geometry = new THREE.RingGeometry(ir, or, ts);
    material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
    mesh = new THREE.Mesh(geometry, material);

    mesh.rotation.y = Math.PI / 2;
    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function getRandomArbitrary(min, max) {
    return Math.floor(Math.random() * (max - min) + min);
}

function detectSphereSphereCollision(s1, s2) {
    return distanceAB(s1, s2) <= 2* ball_radius;
}

function distanceAB(s1, s2) {
    return Math.sqrt(Math.pow(s1.x - s2.x, 2) + Math.pow(s1.z - s2.z, 2));
}