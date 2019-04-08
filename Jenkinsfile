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
                sh ''' git clone  --branch master --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/debsource-reco.git'''   
                sh '''cd debsource-reco && git clone --branch release_20190411 --depth=1 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/object_tracer.git '''   
            }             
            container('pr228') {
                sh 'ls -al'
                stage('Pull DLF'){
                     withCredentials([usernamePassword(credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', 
                     usernameVariable: 'GITHUB_ACCOUNT',passwordVariable:'GITHUB_PASSWORD')]){
                        sh 'git config --global credential.helper cache'
                        sh ''' git clone --depth=1 --branch dlf_release_tag_v2.1.3.19.04.01 https://"$GITHUB_ACCOUNT":"$GITHUB_PASSWORD"@github.com/aeolusbot/deep_learning_framework.git dlf_source'''   
                        sh 'cd dlf_source && git lfs pull '
                    }         
                    //dir('dlf_source') {
                    //    git changelog: false, credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', poll: false, url: 'https://github.com/aeolusbot/deep_learning_framework.git'
                    //}
                    sh 'ls -al dlf_source'
                }
                stage('Setup DLF'){
                    sh 'apt-get update && apt-get install -y nuitka '
                    dir('dlf_source') {
                        sh 'wget http://192.168.15.33:8889/files/jenkins/setup.sh -O script/setup.sh && chmod 755 script/setup.sh'
                        sh '''sed -i \'s/DLF_TENSORRT_ENABLE = True/DLF_TENSORRT_ENABLE = False/g\' dlf_config.py'''
                        sh '''sed -i \'s/DLF_TENSORFLOW_ENABLE = True/DLF_TENSORFLOW_ENABLE = False/g\' dlf_config.py'''
                        sh 'cat dlf_config.py'
                        sh '. ./script/env.sh && ./setup.py'
                    }
                }
                stage('Setup Debsource'){
                    dir('aptsource') {
                        git changelog: false, credentialsId: '93cd491a-412b-41dd-b613-891fc6bd8a88', poll: false, url: 'https://github.com/aeolusbot/docker-images.git'
                    }
                    sh 'cp -r aptsource/src/xenial/apt/preferences.d /etc/apt/'
                    sh 'cp -r aptsource/src/xenial/apt/sources.list.d /etc/apt/'
                    sh 'cp -r aptsource/src/xenial/apt/trusted.gpg.d /etc/apt/'

                    sh 'apt-get update && apt-get install -y devscripts build-essential fakeroot ros-kinetic-opencv3 libopencv-dev libopenblas-base debhelper cython'
                    sh 'apt install -y libopenblas-dev'
                    
                }            
                stage('Build Debsource'){
                    //sh 'sleep 8h'
                   
                    //sh 'cp -r dlf_source/inference/model/caffe debsource-reco/deep_learning_framework/inference/model/'
                    //sh 'cp -r dlf_source/inference/model/torch debsource-reco/deep_learning_framework/inference/model/'
                    sh 'cp -r dlf_source/release debsource-reco/deep_learning_framework/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/feature_extraction/*.npy debsource-reco/model/feature_extraction/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/tree/released_tree/* debsource-reco/model/tree/released_tree/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/link_sim_model/* debsource-reco/model/link_sim_model/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/pd_clf_model/* debsource-reco/model/pd_clf_model/'
                    sh 'cp -r /mnt/grain5-dataset/Aeolus_ModelDataset/Object_tracer/model/reid/* debsource-reco/model/reid/'
                    dir("debsource-reco") {
                        //sh '''sed -i \'s/20190221/'''+"$Release_Date"+'''/g\' debian/files'''
                        //sh 'wget http://192.168.15.33:8889/files/jenkins/copy_model.py'
                        sh '''sed -i \'s/None/"general"/g\' object_tracer/config/config_ot.py'''
                        sh 'cd ../dlf_source && . ./script/env.sh &&cd ../debsource-reco/object_tracer && . ./env/g5_ot_robot2_rel.sh && cd .. && python copy_model.py'
                        sh 'touch deep_learning_framework/release/trt_model.so && rosdep init && rosdep update'
                        //sh 'sleep 8h'
                        sh 'chmod 755 build.bash && ./build.bash'
                        sh 'cp *.deb /mnt/jenkins/debsource/'
                        sh 'cp *.deb /mnt/upload/colinkao/dqa_sys_package'
                    }
                }
            }
        }
    }
