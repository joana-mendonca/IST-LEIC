var camera, scene, renderer, clock, deltaTime;

var geometry, material, mesh;

var map = {};

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
    createCamera();
    
    render();
    
    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("keyup", onKeyUp);
    window.addEventListener("resize", onResize);
}

// -------------------------------------------------------------------------------------------- //
//                                           UPDATING                                           //
// -------------------------------------------------------------------------------------------- //
function update() {
    deltaTime = clock.getDelta();

    // vehicle rotation
    if (map['a'] && !map['s']) scene.getObjectByName('limb').rotation.y += Math.PI / (5000 * deltaTime);
    if (map['s'] && !map['a']) scene.getObjectByName('limb').rotation.y -= Math.PI / (5000 * deltaTime);

    // arm rotations
    if (map['w'] && !map['q']) rotateArm(-1);
    if (map['q'] && !map['w']) rotateArm(1);

    // vehicle movement
    if (map['ArrowUp'] && !map['ArrowDown']) scene.getObjectByName('vehicle').translateX(40 * deltaTime);
    if (map['ArrowDown'] && !map['ArrowUp']) scene.getObjectByName('vehicle').translateX(-40 * deltaTime);
    if (map['ArrowLeft'] && !map['ArrowRight']) scene.getObjectByName('vehicle').translateZ(-40 * deltaTime);
    if (map['ArrowRight'] && !map['ArrowLeft']) scene.getObjectByName('vehicle').translateZ(40 * deltaTime);

    render();

    requestAnimationFrame(update);
}

function rotateArm(v) {
    var next_position = scene.getObjectByName('limb').rotation.z + (v * Math.PI / (5000 * deltaTime));

    if (Math.abs(next_position) <= .8)
        scene.getObjectByName('limb').rotation.z = next_position;
}

function changeCameraAngle(cam, x, y, z) {
    cam.position.x = x;
    cam.position.y = y;
    cam.position.z = z;
    cam.lookAt(scene.position);

    render();
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
    var ee = e.key;

    switch (ee) {
        case '1':  //1 - normal view
            changeCameraAngle(camera, 50, 30, 50);
            break;
        case '2':  //2 - side view
            changeCameraAngle(camera, 0, 0, 50);
            break;
        case '3':  //3 - front view
            changeCameraAngle(camera, 50, 0, 0);
            break;
        case '4':  //4 - toggle wireframe
            scene.traverse(function (node) {
                if (node instanceof THREE.Mesh) {
                    node.material.wireframe = !node.material.wireframe;
                }
            });
            break;
        case 'A':
        case 'S':
        case 'Q':
        case 'W':
            ee = ee.toLowerCase();
        default:
            map[ee] = true;
            break;
    }
}

function onKeyUp(e) {
    var ee = e.key;

    switch (ee) {
        case 'A':
        case 'S':
        case 'Q':
        case 'W':
            ee = ee.toLowerCase();
        default:
            map[ee] = false;
            break;
    }
}

function onResize() {
    'use strict';

    renderer.setSize(window.innerWidth, window.innerHeight);

    camera.left = -window.innerWidth / 20;
    camera.right = window.innerWidth / 20;
    camera.top = window.innerHeight / 20;
    camera.bottom = -window.innerHeight / 20;
    camera.updateProjectionMatrix();
}

// -------------------------------------------------------------------------------------------- //
//                                        CAMERA CREATION                                       //
// -------------------------------------------------------------------------------------------- //
function createCamera() {
    'use strict';

    camera = new THREE.OrthographicCamera(
        window.innerWidth/-20, window.innerWidth/20,
        window.innerHeight/20, window.innerHeight/-20,
        1,
        1000);

    changeCameraAngle(camera, 50, 30, 50);

    scene.add(camera);
}

// -------------------------------------------------------------------------------------------- //
//                                        SCENE CREATION                                        //
// -------------------------------------------------------------------------------------------- //
function createScene() {
    'use strict';
    
    scene = new THREE.Scene();
    
    // scene.add(new THREE.AxisHelper(10));
    
    createVehicle(scene, 0, 0, 0);
    createTarget(scene, 30, 0, 0);
}

// creation of Object3Ds
function createVehicle(obj, x, y, z) {
    'use strict';

    var vehicle = new THREE.Object3D();
    vehicle.name = 'vehicle';

    createCar(vehicle, 0, 0, 0);
    createLimb(vehicle, 0, 6, 0);

    vehicle.position.set(x, y, z);
    obj.add(vehicle);
    // vehicle.add(new THREE.AxisHelper(10));
}

function createTarget(obj, x, y, z) {
    'use strict';

    var target = new THREE.Object3D();
    target.name = 'target';

    addCylinder(target, 3, 3, 20, 20, 0, 10, 0);
    addTorus(target, 3, .5, 10, 20, 0, 23.5, 0);

    target.position.set(x, y, z);
    obj.add(target);
}

function createCar(obj, x, y, z) {
    'use strict';

    var car = new THREE.Object3D();
    car.name = 'car';

    addBox(car, 20, 2, 14, 0, 5, 0);
    addSphere(car, 2, 15, 15, 8, 2, 5);
    addSphere(car, 2, 15, 15, 8, 2, -5);
    addSphere(car, 2, 15, 15, -8, 2, 5);
    addSphere(car, 2, 15, 15, -8, 2, -5);
    addSemiSphere(car, 0, 6, 0)

    car.position.set(x, y, z);
    obj.add(car);
}

function createLimb(obj, x, y, z) {
    'use strict';

    var limb = new THREE.Object3D();
    limb.name = 'limb';

    addBox(limb, 2, 16, 2, 0, 8, 0);
    addSphere(limb, 2, 15, 15, 0, 16, 0);
    createForearm(limb, 0, 16, 0);

    limb.position.set(x, y, z);
    obj.add(limb);
    // limb.add(new THREE.AxisHelper(6));
}

function createForearm(obj, x, y, z) {
    'use strict';

    var forearm = new THREE.Object3D();
    forearm.name = 'forearm';

    addBox(forearm, 16, 2, 2, 8, 0, 0);
    addSphere(forearm, 2, 15, 15, 16, 0, 0);
    createHand(forearm, 16, 0, 0);

    forearm.position.set(x, y, z);
    obj.add(forearm);
    // forearm.add(new THREE.AxisHelper(6));
}

function createHand(obj, x, y, z) {
    'use strict';

    var hand = new THREE.Object3D();
    hand.name = 'hand';

    addBox(hand, .5, 4, 4, 2.25, 0, 0);
    addBox(hand, 3, .5, 2, 4, 1.25, 0)
    addBox(hand, 3, .5, 2, 4, -1.25, 0)

    hand.position.set(x, y, z);
    obj.add(hand);
    // hand.add(new THREE.AxisHelper(6));
}

// geometry creation functions
function addBox(obj, dx, dy, dz, x, y, z) {
    'use strict';

    geometry = new THREE.BoxGeometry(dx, dy, dz);
    material = new THREE.MeshBasicMaterial({ color: 0x00ff00, wireframe: true });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addSphere(obj, r, ws, hs, x, y, z) {
    'use strict';

    geometry = new THREE.SphereGeometry(r, ws, hs);
    material = new THREE.MeshBasicMaterial({ color: 0xff0000, wireframe: true });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addSemiSphere(obj, x, y, z) {
    'use strict';

    geometry = new THREE.SphereGeometry(3, 15, 15, 0, 2 * Math.PI, 0, 0.5 * Math.PI);
    material = new THREE.MeshBasicMaterial({ color: 0xff0000, wireframe: true });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addCylinder(obj, rt, rb, len, rs, x, y, z) {
    'use strict';

    geometry = new THREE.CylinderGeometry(rt, rb, len, rs);
    material = new THREE.MeshBasicMaterial({ color: 0x00ffff, wireframe: true });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addTorus(obj, r, t, rs, ts, x, y, z) {
    'use strict';

    geometry = new THREE.TorusGeometry(r, t, rs, ts);
    material = new THREE.MeshBasicMaterial({ color: 0xff00ff, wireframe: true });
    mesh = new THREE.Mesh(geometry, material);

    mesh.position.set(x, y, z);
    obj.add(mesh);
    mesh.rotation.y = Math.PI / 2;
}