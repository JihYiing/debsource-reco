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
            withCredentials([usernamePassword(credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', 
                usernameVariable: 'GITHUB_ACCOUNT',passwordVariable:'GITHUB_PASSWORD')]){
                sh 'git config --global credential.helper cache'
                sh ''' git clone --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/debsource-reco.git --branch master'''   
                sh 'cd debsource-reco && git submodule update --init '
            }                
            container('pr228') {
                sh 'ls -al'
                stage('Pull DLF'){
                    dir('dlf_source') {
                        git changelog: false, credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', poll: false, url: 'https://github.com/aeolusbot/deep_learning_framework.git'
                    }
                    sh 'ls -al dlf_source'
                }
                stage('Setup DLF'){
                    sh 'apt update && apt-get install -y nuitka '
                    sh 'cd dlf_source && . ./script/env.sh && ./setup.py'
                    
                }
                stage('Setup Debsource'){
                    dir('aptsource') {
                        git changelog: false, credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', poll: false, url: 'https://github.com/aeolusbot/docker-images.git'
                    }
                    sh 'cp -r aptsource/src/apt/preferences.d /etc/apt/'
                    sh 'cp -r aptsource/src/apt/sources.list.d /etc/apt/'
                    sh 'cp -r aptsource/src/apt/trusted.gpg.d /etc/apt/'

                    sh 'apt update && apt-get install -y devscripts build-essential fakeroot ros-kinetic-opencv3 libopencv-dev libopenblas-base debhelper cython'
                    sh 'apt install -y libopenblas-dev'
                    
                }            
                stage('Build Debsource'){
                    sh 'cp -r dlf_source/release/* debsource-reco/deep_learning_framework/release/'
                    dir("debsource-reco") {
                        sh 'touch deep_learning_framework/release/trt_model.so && rosdep init'
                        sh 'chmod 755 build.bash && ./build.bash'
                        sh 'cp *.deb /mnt/jenkins/debsource/'
                    }
                }
            }
        }
    }
