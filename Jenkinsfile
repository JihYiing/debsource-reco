def label = 'debsource-reco'
def commitSHA
podTemplate(label: label,
        containers: [
            containerTemplate(ttyEnabled: true, command: 'cat', envVars: [envVar(key: 'TZ', value: 'Asia/Taipei')], image: '192.168.15.59/grain5/ros-base:pr228', name: 'pr228'),
        ]
        ,volumes: [
    nfsVolume(mountPath: '/mnt/grain5-dataset', readOnly: false, serverAddress: '192.168.15.99', serverPath: '/volume2/grain5-dataset'),
    nfsVolume(mountPath: '/mnt/grain5-dataset2', readOnly: false, serverAddress: '192.168.15.99', serverPath: '/volume1/grain5-dataset2'),
    nfsVolume(mountPath: '/mnt/jenkins', readOnly: false, serverAddress: '192.168.15.99', serverPath: '/volume1/jenkins'),
    nfsVolume(mountPath: '/mnt/Public_Dataset', readOnly: false, serverAddress: '192.168.15.99', serverPath: '/volume3/Public_Dataset'),
    nfsVolume(mountPath: '/mnt/upload', readOnly: false, serverAddress: '192.168.15.98', serverPath: '/volume3/upload'),
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
        node(label) {
                    
            container('pr228') {
                stage('Pull Source Code'){
                    withCredentials([usernamePassword(credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', 
                        usernameVariable: 'GITHUB_ACCOUNT',passwordVariable:'GITHUB_PASSWORD')]){
                        sh 'git config --global credential.helper cache'
                        sh '''git clone  --branch master --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/debsource-reco.git'''
                        dir("debsource-reco"){ 
                            sh '''git clone --branch release_20190511 --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/object_tracer.git ''' +
                               '''&& cd object_tracer && git submodule init && git submodule update --remote'''   
                        }
                    }     
                }
                stage('Setup Debsource'){
                    dir('aptsource') {
                        git changelog: false, credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', poll: false, url: 'https://github.com/aeolusbot/docker-images.git'
                    }
                    sh 'cp -r aptsource/src/xenial/apt/preferences.d /etc/apt/'
                    sh 'cp -r aptsource/src/xenial/apt/sources.list.d /etc/apt/'
                    sh 'cp -r aptsource/src/xenial/apt/trusted.gpg.d /etc/apt/'
                    sh 'apt-get update && apt-get install -y nuitka devscripts build-essential fakeroot ros-kinetic-opencv3 libopencv-dev libopenblas-base debhelper cython'
                    sh 'apt install -y libopenblas-dev'
                    
                }            
                stage('Build Debsource'){
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/feature_extraction/*.npy debsource-reco/model/feature_extraction/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/tree/released_tree/* debsource-reco/model/tree/released_tree/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/link_sim_model/* debsource-reco/model/link_sim_model/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/reid/* debsource-reco/model/reid/'
                    dir("debsource-reco") {
                        sh 'cd object_tracer/libs/dlf &&. ./script/env.sh && python setup.py'
                        sh 'rosdep init && rosdep update'
                        sh './build.bash'
                        sh 'cp *.deb /mnt/jenkins/debsource/'
                        sh 'cp *.deb /mnt/upload/colinkao/dqa_sys_package'
                    }
                }
            }
        }
    }
