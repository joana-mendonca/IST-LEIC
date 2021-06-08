var geometry, material, mesh, map = {}, directionalLight;

var cameras = [],
    camera_active = 1,
    scene, renderer, clock, deltaTime, t;

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
    createCamera(0, 1, {'x': 0, 'y': 90, 'z': 0}, 100, 180, 180);
    createCamera(1, 0, {'x': 0, 'y': 100, 'z': 0}, 0, 100, 150);
    
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
        case 'q':
        case 'Q':
            ee = ee.toLowerCase();
            if (map[ee]) break;
            map[ee] = true;

            directionalLight.visible = !directionalLight.visible;
            break;
        case 'e':
        case 'E':
            ee = ee.toLowerCase();
            if (map[ee]) break;
            map[ee] = true;

            scene.traverse(function (node) {
                if (node instanceof THREE.Mesh)
                    node.material = node.userData.ms[(node.userData.ms.indexOf(node.material) + 1) % 3];
            });
            break;
        case '5':
            camera_active = 0;
            break;
        case '6':
            camera_active = 1;
            break;
    }
}

function onKeyUp(e) {
    var ee = e.key;

    switch (ee) {
        case 'q':
        case 'Q':
        case 'e':
        case 'E':
            ee = ee.toLowerCase();
            map[ee] = false;
            break;
    }
}

function onResize() {
    'use strict';

    renderer.setSize(window.innerWidth, window.innerHeight);

    if (window.innerHeight > 0 && window.innerWidth > 0) {
        cameras[0].aspect = window.innerWidth / window.innerHeight;
        cameras[0].updateProjectionMatrix();
    }

    cameras[1].left = -window.innerWidth / 8;
    cameras[1].right = window.innerWidth / 8;
    cameras[1].top = window.innerHeight / 8;
    cameras[1].bottom = -window.innerHeight / 8;
    cameras[1].updateProjectionMatrix();
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

    createOPArt(scene, -75, 130, 0);
    createPedestal(scene, 75, 4, 20);
    addBox(scene, 300, 200, 4, 0xf0c5e3, 0, 100, -4);
    addBox(scene, 300, 4, 104, 0xd5e9f2, 0, 2, 50);

    directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(0, 200, 150);
    scene.add(directionalLight);
    directionalLight.castShadow = true;
    scene.add(new THREE.DirectionalLightHelper( directionalLight, 5 ));


    scene.add(new THREE.AxisHelper(10));
}

function createOPArt(obj, x, y, z) {
    'use strict';

    var o3d = new THREE.Object3D();

    addBox(o3d, 79, 61, 4, 0x888888, 0, 0, 0);

    addBox(o3d, 79, 4, 4, 0x824100, 0, 32.5, 2);
    addBox(o3d, 79, 4, 4, 0x824100, 0, -32.5, 2);
    addBox(o3d, 4, 69, 4, 0x824100, 41.5, 0, 2);
    addBox(o3d, 4, 69, 4, 0x824100, -41.5, 0, 2);

    for (var i = -36; i <= 36; i -= -6) {
        for (var j = -27; j <= 27; j -= -6) {
            addBox(o3d, 5, 5, 2, 0x000000, i, j, 2);
        }
    }

    for (var i = -33; i <= 36; i -= -6) {
        for (var j = -24; j <= 24; j -= -6) {
            addCylinder(o3d, 1, 1, 2, 10, [Math.PI / 2, 0, 0], 0xffffff, i, j, 2);
        }
    }

    o3d.position.set(x, y, z);
    obj.add(o3d);
}

function createPedestal(obj, x, y, z) {
    'use strict';

    var o3d = new THREE.Object3D();

    addCylinder(o3d, 20, 20, 4, 20, [0, 0, 0], 0xfffcf7, 0, 2, 0);
    addCylinder(o3d, 12, 20, 4, 20, [0, 0, 0], 0xfffcf7, 0, 6, 0);
    addCylinder(o3d, 12, 12, 60, 20, [0, 0, 0], 0xfffcf7, 0, 38, 0);
    addCylinder(o3d, 20, 20, 4, 20, [0, 0, 0], 0xfffcf7, 0, 70, 0);

    o3d.position.set(x, y, z);
    obj.add(o3d);
}

// geometry creation functions
function addBox(obj, dx, dy, dz, c, x, y, z) {
    'use strict';

    geometry = new THREE.BoxGeometry(dx, dy, dz);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    mesh.castShadow = true;
    mesh.receiveShadow = true;

    mesh.position.set(x, y, z);

    obj.add(mesh);
}

function addCylinder(obj, rt, rb, len, rs, rot, c, x, y, z) {
    'use strict';

    geometry = new THREE.CylinderGeometry(rt, rb, len, rs);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    mesh.castShadow = true;
    mesh.receiveShadow = true;

    mesh.rotation.x = rot[0];
    mesh.rotation.y = rot[1];
    mesh.rotation.z = rot[2];
    mesh.position.set(x, y, z);
    obj.add(mesh);
}