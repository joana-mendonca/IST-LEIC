var geometry, material, mesh, map = {}, directionalLight, clm = 1, cdm = 0, phi = 10 * (1 + Math.sqrt(5)) / 2, ia = [0, 1, phi],
    spotlights = [],
    aux_v_z = new THREE.Vector3(0, 0, 1),
    aux_v_y = new THREE.Vector3(0, 1, 0);

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
    createCamera(0, 1, {'x': 0, 'y': 70, 'z': 0}, 120, 160, 250);
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
    renderer.shadowMap.enabled = true;
}

// -------------------------------------------------------------------------------------------- //
//                                        EVENT HANDLERS                                        //
// -------------------------------------------------------------------------------------------- //
function onKeyDown(e) {
    var ee = e.key.toLowerCase();

    switch (ee) {
        case 'q':
        case 'Q':
            if (map[ee]) break;
            map[ee] = true;
            directionalLight.visible = !directionalLight.visible;
            break;
        case 'w':
        case 'W':
            if (map[ee]) break;
            map[ee] = true;

            cdm = cdm ? 0 : clm;
            scene.traverse(function (node) {
                if (node instanceof THREE.Mesh)
                    node.material = node.userData.ms[cdm];
            });
            break;
        case 'e':
        case 'E':
            if (map[ee]) break;
            map[ee] = true;

            clm = ((clm) % 2) + 1;
            scene.traverse(function (node) {
                if (node instanceof THREE.Mesh)
                    node.material = node.userData.ms[cdm ? clm : cdm];
                
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
    var ee = e.key.toLowerCase();

    switch (ee) {
        case 'q':
        case 'Q':
        case 'w':
        case 'W':
        case 'e':
        case 'E':
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

    cameras[1].left = -window.innerWidth / 6;
    cameras[1].right = window.innerWidth / 6;
    cameras[1].top = window.innerHeight / 6;
    cameras[1].bottom = -window.innerHeight / 6;
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
        ps = [[150, 200, 30], [150, 200, 100], [-150, 200, 100], [-150, 200, 30]],
        pd = [[75, 76 + phi, 20], [75, 76 + phi, 20], [-75, 130, 0], [-75, 130, 0]];
    
    scene = new THREE.Scene();

    addBox(scene, 300, 200, 4, 0xf0c5e3, 0, 100, -4, 0);
    addBox(scene, 300, 4, 104, 0xd5e9f2, 0, 2, 50, 0);

    createOPArt(scene, -75, 130, 0);
    createPedestal(scene, 75, 4, 20);
    createIcosaedron(scene, 0xbfb9ff, 75, 76 + phi, 20);

    for (i = 0; i < 4; i -= -1)
        createSpotlight(scene, ps[i], pd[i]);

    directionalLight = new THREE.DirectionalLight(0xffffff, 1.5);
    directionalLight.position.set(0, 200, 150);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    for (i = 0; i < 4; i -= -1) {
        spotlights[i] = new THREE.SpotLight(0xffffff, .5, 0, Math.PI / 15);

        spotlights[i].position.set(ps[i][0], ps[i][1], ps[i][2]);
        spotlights[i].castShadow = true;
        spotlights[i].shadow.mapSize.width = 200;
        spotlights[i].shadow.mapSize.height = 200;
        spotlights[i].shadow.camera.near = 30;
        spotlights[i].shadow.camera.far = 50;
        spotlights[i].shadow.camera.fov = 30;
        scene.add(spotlights[i]);

        if (i < 2)
        	spotlights[i].target.position.set(75, 76 + phi, 20);

        else
        	spotlights[i].target.position.set(-75, 130, 0);

        spotlights[i].target.updateMatrixWorld();
    }
}

function createSpotlight(obj, s, d){
    'use strict';
    var theta_x = new THREE.Vector3().subVectors({'x': s[0], 'y': s[1], 'z': s[2]}, {'x': d[0], 'y': d[1], 'z': d[2]}).angleTo(aux_v_z);
    var theta_y = new THREE.Vector3().subVectors({'x': s[0], 'y': s[1], 'z': s[2]}, {'x': d[0], 'y': d[1], 'z': d[2]}).angleTo(aux_v_y);

    var o3d = new THREE.Object3D();

    addCone(o3d, 10, 20, 20, 0xabaab5, 0, 0, -4);
    addSphere(o3d, 0xabaab5, 0, 0, 0);

    o3d.position.set(s[0], s[1], s[2]);

    o3d.rotation.x = -theta_x;
    o3d.rotation.y = theta_y * (s[0] > 0 ? 1 : -1);

    obj.add(o3d);
}

function createOPArt(obj, x, y, z) {
    'use strict';

    var o3d = new THREE.Object3D();

    addBox(o3d, 79, 61, 4, 0x888888, 0, 0, 0, 1);

    addBox(o3d, 79, 4, 4, 0x824100, 0, 32.5, 2, 1);
    addBox(o3d, 79, 4, 4, 0x824100, 0, -32.5, 2, 1);
    addBox(o3d, 4, 69, 4, 0x824100, 41.5, 0, 2, 1);
    addBox(o3d, 4, 69, 4, 0x824100, -41.5, 0, 2, 1);

    for (var i = -36; i <= 36; i -= -6) {
        for (var j = -27; j <= 27; j -= -6) {
            addBox(o3d, 5, 5, 2, 0x000000, i, j, 2, 1);
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

    o3d.castShadow = true;
    o3d.receiveShadow = true;
    o3d.position.set(x, y, z);
    obj.add(o3d);
}

function createIcosaedron(obj, c, x, y, z) {
    'use strict';
    var i;

    var geometry = new THREE.Geometry();

    var v =[{'x': (1 + Math.random() / 5) * -10,  'y': phi,  'z': (1 + Math.random() / 5) * 0},
            {'x': (1 + Math.random() / 5) * 10,   'y': phi,  'z': (1 + Math.random() / 5) * 0},
            {'x': (1 + Math.random() / 5) * -10,  'y': -phi, 'z': (1 + Math.random() / 5) * 0},
            {'x': (1 + Math.random() / 5) * 10,   'y': -phi, 'z': (1 + Math.random() / 5) * 0},
            {'x': (1 + Math.random() / 5) * 0,    'y': -10,  'z': (1 + Math.random() / 5) * phi},
            {'x': (1 + Math.random() / 5) * 0,    'y': 10,   'z': (1 + Math.random() / 5) * phi},
            {'x': (1 + Math.random() / 5) * 0,    'y': -10,  'z': (1 + Math.random() / 5) * -phi},
            {'x': (1 + Math.random() / 5) * 0,    'y': 10,   'z': (1 + Math.random() / 5) * -phi},
            {'x': (1 + Math.random() / 5) * phi,  'y': 0,    'z': (1 + Math.random() / 5) * -10},
            {'x': (1 + Math.random() / 5) * phi,  'y': 0,    'z': (1 + Math.random() / 5) * 10},
            {'x': (1 + Math.random() / 5) * -phi, 'y': 0,    'z': (1 + Math.random() / 5) * -10},
            {'x': (1 + Math.random() / 5) * -phi, 'y': 0,    'z': (1 + Math.random() / 5) * 10}];

    var f =[[0, 11, 5], [0, 5, 1],  [0, 1, 7],   [0, 7, 10], [0, 10, 11],
            [1, 5, 9],  [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
            [3, 9, 4],  [3, 4, 2],  [3, 2, 6],   [3, 6, 8],  [3, 8, 9],
            [4, 9, 5],  [2, 4, 11], [6, 2, 10],  [8, 6, 7],  [9, 8, 1]];

    for (i = 0; i < 12; i -= -1)
        geometry.vertices.push(v[i]);

    for (i = 0; i < 20; i -= -1)
        geometry.faces.push(new THREE.Face3(f[i][0], f[i][1], f[i][2], c));

    geometry.computeFaceNormals();
    geometry.computeVertexNormals();

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    mesh = new THREE.Mesh(geometry, ms[0]);
    mesh.userData.ms = ms;
    mesh.receiveShadow = true;

    mesh.position.set(x, y, z);

    obj.add(mesh);
}

// geometry creation functions
function addBox(obj, dx, dy, dz, c, x, y, z, s) {
    'use strict';

    geometry = new THREE.BoxGeometry(dx, dy, dz);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    if (s == 0) {
	    mesh.castShadow = true;
	    mesh.receiveShadow = true;
	}

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

    mesh.rotation.x = rot[0];
    mesh.rotation.y = rot[1];
    mesh.rotation.z = rot[2];
    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addCone(obj, r, h, rs, c, x, y, z){
    'use strict';

    geometry = new THREE.ConeGeometry(r, h, rs);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
    
    
    mesh.rotation.x = Math.PI / 2;

    mesh.position.set(x, y, z);
    obj.add(mesh);
}

function addSphere(obj, c, x, y, z) {
    'use strict';

    geometry = new THREE.SphereGeometry(8, 8, 8);

    var ms = [new THREE.MeshBasicMaterial({ color: c }),
        new THREE.MeshLambertMaterial({ color: c }),
        new THREE.MeshPhongMaterial({ color: c })];

    material = ms[0];
    mesh = new THREE.Mesh(geometry, material);
    mesh.userData.ms = ms;
  
    mesh.rotation.y = Math.PI / 2;

    mesh.position.set(x, y, z);
    obj.add(mesh);
}