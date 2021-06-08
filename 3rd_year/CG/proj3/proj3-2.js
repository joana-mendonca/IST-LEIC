var geometry, material, mesh, map = {}, directionalLight, clm = 1, cdm = 0, phi = (1 + Math.sqrt(5)) / 2, ia = [0, 1, phi],
    spotlights = [];

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
        case 'w':
        case 'W':
            ee = ee.toLowerCase();
            if (map[ee]) break;
            map[ee] = true;

            cdm = cdm ? 0 : clm;
            console.log(cdm)
            scene.traverse(function (node) {
                if (node instanceof THREE.Mesh) {
                    node.material = node.userData.ms[cdm];
                }
            });
            break;
        case 'e':
        case 'E':
            ee = ee.toLowerCase();
            if (map[ee]) break;
            map[ee] = true;

            clm = ((clm) % 2) + 1;
            scene.traverse(function (node) {
                if (node instanceof THREE.Mesh) {
                    node.material = node.userData.ms[cdm ? clm : cdm];
                }
            });
            break;
        case '1':
        case '2':
        case '3':
        case '4':
            spotlights[ee - 1].visible = !spotlights[ee - 1].visible;
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
        case 'w':
        case 'W':
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
            window.innerWidth/-6, window.innerWidth/6,
            window.innerHeight/6, window.innerHeight/-6,
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
    var n, nx, nz, i,
        ps = [[-75, 130, 125], [-10, 100, 125], [45, 70, 125], [90, 30, 125]];
    
    scene = new THREE.Scene();

    createOPArt(scene, -75, 130, 0);
    createPedestal(scene, 75, 4, 20);
    createSpotlight(scene, 90, 30, 125);
    createSpotlight(scene, 45, 70, 125);
    createSpotlight(scene, -10, 100, 125);
    createSpotlight(scene, -75, 130, 125);
    createIcosaedron(scene, 0xbfb9ff, 75, 76 + 10 * phi, 20);
    addBox(scene, 300, 200, 4, 0xf0c5e3, 0, 100, -4);
    addBox(scene, 300, 4, 104, 0xd5e9f2, 0, 2, 50);

    directionalLight = new THREE.DirectionalLight(0xffffff, 1.5);
    directionalLight.position.set(0, 200, 150);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    for (i = 0; i < 4; i++) {
        spotlights[i] = new THREE.SpotLight(0xffffff, .5, 0, Math.PI/20);
        spotlights[i].position.set(ps[i][0], ps[i][1], ps[i][2]);
        spotlights[i].castShadow = true;
        spotlights[i].shadow.mapSize.width = 200;
        spotlights[i].shadow.mapSize.height = 200;
        spotlights[i].shadow.camera.near = 10;
        spotlights[i].shadow.camera.far = 50;
        spotlights[i].shadow.camera.fov = 30;
        scene.add(spotlights[i]);
        spotlights[i].target.position.set(ps[i][0], ps[i][1], 0);
        spotlights[i].target.updateMatrixWorld();
        scene.add(new THREE.SpotLightHelper( spotlights[i] ));
    }
    
    /*scene.add(new THREE.AxisHelper(300));*/
}

function createSpotlight(obj, x, y, z){
    'use strict';

    var o3d = new THREE.Object3D();

    addCone(o3d, 10, 15, 20, 0, 0, 7, 0xabaab5);
    addSemiSphere(o3d, 0, 0, 0, 0xfbff00);

    o3d.position.set(x, y, z);
    obj.add(o3d);
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

function addCone(obj, r, h, rs, x, y, z, c){
    'use strict';

    geometry = new THREE.ConeGeometry(r, h, rs);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    mesh.castShadow = true;
    mesh.receiveShadow = true;

    mesh.rotation.x = Math.PI / 2;

    mesh.position.set(x, y, z);
    obj.add(mesh);

}

function addSemiSphere(obj, x, y, z, c) {
    'use strict';

    geometry = new THREE.SphereGeometry(10, 10, 10, Math.PI / 2, Math.PI, 0, Math.PI);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    mesh.castShadow = true;
    mesh.receiveShadow = true;

    mesh.rotation.y = Math.PI / 2;

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function createIcosaedron(obj, c, x, y, z) {
    'use strict';
    var i, j, ia1;

    var geometry = new THREE.Geometry();

/*    for (i = 0; i < 3; i -= -1) {
        for (j = 0; j < 4; j -= -1) {
            geometry.vertices.push({'x': ia[0], 'y': ia[1], 'z': ia[2]});
            geometry.vertices.push({'x': ia[0], 'y': ia[1], 'z': ia[2]});
            geometry.vertices.push({'x': ia[0], 'y': ia[1], 'z': ia[2]});
            geometry.vertices.push({'x': ia[0], 'y': ia[1], 'z': ia[2]});
        }

        ia1 = ia.shift();
        ia.push(ia1);
    }*/

    geometry.vertices.push({'x': 0, 'y': 10, 'z': 10 * phi});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 0, y + 10, z + 10 * phi);*/
    geometry.vertices.push({'x': 0, 'y': -10, 'z': 10 * phi});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 0, y + -10, z + 10 * phi);*/
    geometry.vertices.push({'x': 0, 'y': 10, 'z': -10 * phi});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 0, y + 10, z + -10 * phi);*/
    geometry.vertices.push({'x': 0, 'y': -10, 'z': -10 * phi});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 0, y + -10, z + -10 * phi);*/

    geometry.vertices.push({'x': 10 * phi, 'y': 0, 'z': 10});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 10 * phi, y + 0, z + 10);*/
    geometry.vertices.push({'x': 10 * phi, 'y': 0, 'z': -10});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 10 * phi, y + 0, z + -10);*/
    geometry.vertices.push({'x': -10 * phi, 'y': 0, 'z': 10});
    /*addBox(scene, 3, 3, 3, 0x000000, x + -10 * phi, y + 0, z + 10);*/
    geometry.vertices.push({'x': -10 * phi, 'y': 0, 'z': -10});
    /*addBox(scene, 3, 3, 3, 0x000000, x + -10 * phi, y + 0, z + -10);*/

    geometry.vertices.push({'x': 10, 'y': 10 * phi, 'z': 0});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 10, y + 10 * phi, z + 0);*/
    geometry.vertices.push({'x': -10, 'y': 10 * phi, 'z': 0});
    /*addBox(scene, 3, 3, 3, 0x000000, x + -10, y + 10 * phi, z + 0);*/
    geometry.vertices.push({'x': 10, 'y': -10 * phi, 'z': 0});
    /*addBox(scene, 3, 3, 3, 0x000000, x + 10, y + -10 * phi, z + 0);*/
    geometry.vertices.push({'x': -10, 'y': -10 * phi, 'z': 0});
    /*addBox(scene, 3, 3, 3, 0x000000, x + -10, y + -10 * phi, z + 0);*/

    geometry.faces.push(new THREE.Face3(8, 2, 5, c));
    geometry.faces.push(new THREE.Face3(2, 7, 9, c));
    geometry.faces.push(new THREE.Face3(2, 9, 8, c));
    geometry.faces.push(new THREE.Face3(0, 9, 8, c));
    geometry.faces.push(new THREE.Face3(0, 8, 4, c));
    geometry.faces.push(new THREE.Face3(0, 4, 3, c));
    geometry.faces.push(new THREE.Face3(0, 3, 6, c));
    geometry.faces.push(new THREE.Face3(0, 6, 9, c));
    geometry.faces.push(new THREE.Face3(1, 4, 10, c));
    geometry.faces.push(new THREE.Face3(1, 10, 11, c));
    geometry.faces.push(new THREE.Face3(1, 11, 6, c));
    geometry.faces.push(new THREE.Face3(3, 7, 0, c));
    geometry.faces.push(new THREE.Face3(3, 0, 5, c));
    geometry.faces.push(new THREE.Face3(3, 5, 10, c));
    geometry.faces.push(new THREE.Face3(3, 10, 11, c));
    geometry.faces.push(new THREE.Face3(3, 11, 7, c));
    geometry.faces.push(new THREE.Face3(8, 5, 4, c));
    geometry.faces.push(new THREE.Face3(10, 5, 4, c));
    geometry.faces.push(new THREE.Face3(9, 7, 6, c));
    geometry.faces.push(new THREE.Face3(11, 7, 6, c));

    console.log(geometry.faces)

    geometry.computeFaceNormals();
    geometry.computeVertexNormals();

    var ms = [new THREE.MeshBasicMaterial({ color: c , side: THREE.DoubleSide}),
        new THREE.MeshLambertMaterial({ color: c , side: THREE.DoubleSide}),
        new THREE.MeshPhongMaterial({ color: c , side: THREE.DoubleSide})];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    mesh.castShadow = true;
    mesh.receiveShadow = true;

    mesh.position.set(x, y, z);

    obj.add(mesh);

    console.log(geometry)
}