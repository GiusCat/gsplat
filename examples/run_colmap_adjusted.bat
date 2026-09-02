rem Script taken from https://github.com/smartdatascan/gaussian-splatting-tutorial/tree/main

rem === Set paths ===
set COLMAP_PATH=C:\Users\user\Downloads\colmap-x64-windows-cuda\COLMAP.bat
set GLOMAP_PATH=C:\Users\user\Downloads\glomap-x64-windows-cuda\bin\glomap.exe
set DATA_PATH=C:\Users\user\Downloads\gaussian_lab
set IMAGE_PATH=%DATA_PATH%\images
set DB_PATH=%DATA_PATH%\database.db
set SPARSE_PATH=%DATA_PATH%\sparse

rem === Create output folder if it doesn't exist ===
if not exist %SPARSE_PATH% mkdir %SPARSE_PATH%

rem === Step 1: Feature extraction ===
echo Running feature extraction...
call %COLMAP_PATH% feature_extractor ^
    --database_path %DB_PATH% ^
    --image_path %IMAGE_PATH% ^
    --ImageReader.single_camera 1 ^
    --ImageReader.camera_model PINHOLE ^
    --SiftExtraction.use_gpu 1

rem === Step 2: Feature matching ===
echo Running exhaustive matcher...
call %COLMAP_PATH% exhaustive_matcher ^
    --database_path %DB_PATH% ^
    --SiftMatching.use_gpu 1 ^
    --SiftMatching.guided_matching 1

rem === Step 3: Mapping ===
echo Running mapper...
call %GLOMAP_PATH% mapper ^
    --database_path %DB_PATH% ^
    --image_path %IMAGE_PATH% ^
    --output_path %SPARSE_PATH%

rem call %COLMAP_PATH% mapper ^
rem     --database_path %DB_PATH% ^
rem     --image_path %IMAGE_PATH% ^
rem     --output_path %SPARSE_PATH% ^
rem     --Mapper.init_min_tri_angle 2 ^
rem     --Mapper.init_min_num_inliers 4 ^
rem     --Mapper.abs_pose_min_num_inliers 3 ^
rem     --Mapper.abs_pose_max_error 8
