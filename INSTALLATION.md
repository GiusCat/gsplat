# Qualche info su come far girare il tutto (Windows)

- Molto, estremamente consigliato far girare tutto su un dispositivo con GPU NVidia
- [Guida di riferimento](https://smartdatascan.com/tutorials/gaussian-splatting-windows/) per installazione e uso su Windows
- Configurazione testata: Windows 10, CUDA Toolkit 12.6, PyTorch 2.6.0

## Installazione driver GPU e CUDA Toolkit

Per abilitare l'utilizzo su GPU NVIDIA è necessario

1. Avere i driver della GPU installati; si può verificare che siano installati tramite comando `nvidia-smi`, se non ci sono si può gestire l'installazione da [NVIDIA App](https://www.nvidia.com/it-it/software/nvidia-app/)
2. Scaricare il CUDA Toolkit (versione testata funzionante: [CUDA 12.6](https://developer.nvidia.com/cuda-12-6-0-download-archive)); si può verificare la corretta installazione tramite comando `nvcc -V`

## Installazione Visual Studio BuildTools

Per fare la build della libreria GSplat è necessario avere a disposizione gli SDK C/C++. Su windows è possibile scaricarli attraversi i [BuildTools di Visual Studio](https://visualstudio.microsoft.com/it/visual-cpp-build-tools/) (**NB:** _Non_ serve scaricare _tutto_ Visual Studio!)

1. Dall'installer installare `Visual Studio Build Tools 2022`
2. Dalla finestra di installazione che si apre, nel tab _Carichi di lavoro_ selezionare `Sviluppo di applicazioni desktop con C++`
3. Nel tab _Singoli componenti_ selezionare la voce `MSVC v142`
4. Procedere con l'installazione

Per verificare l'installazione, aprendo il prompt dei comandi ed eseguendo

    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    cl

dovrebbe uscire un output simile al seguente:

    **********************************************************************
    ** Visual Studio 2022 Developer Command Prompt v17.14.19
    ** Copyright (c) 2025 Microsoft Corporation
    **********************************************************************
    [vcvarsall.bat] Environment initialized for: 'x64'

Provando a eseguire il comando `cl` dovrebbe uscire un output simile al seguente:

    Microsoft (R) C/C++ Optimizing Compiler Version 19.43.34809 for x86
    usage: cl [ option... ] filename... [ /link linkoption... ]

## Download COLMAP

Per Windows è possibile recuperare la versione eseguibile di COLMAP, anche compatibile con CUDA, dalla [repository GitHub](https://github.com/colmap/colmap/releases)
 - Nello ZIP c'è lo script `COLMAP.bat`, col doppio click si avvia la GUI oppure lo si può invocare da script

## Installazione Conda

TODO mettere come si installa Conda, e come creare un ambiente

    conda create -y -n gsplat python=3.10
    conda activate gsplat

## Installazione PyTorch

- Serve installare la versione di PyTorch compilata con la versione corretta del CUDA Toolkit installato nei passi precedenti
- Si possono recuperare le varie combinazioni dall'[archivio di PyTorch](https://pytorch.org/get-started/previous-versions/)

**Esempio:** PyTorch v2.6 per CUDA Toolkit 12.6

    pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu126

Verificare che l'installazione funzioni (con CUDA) facendo partire il comando

    python -c "import torch; print(torch.cuda.is_available())"

e verificando che l'output restituisca `True`

<!-- #### Installazione fused-bilagrid (SKIP)

Questo è l'unico package che non riesce a essere installato dal requirements.txt di gsplat, per cui fare

git clone https://github.com/harry7557558/fused-bilagrid.git
cd fused-bilagrid
pip install . --no-build-isolation -->

## Installazione GSplat

Serve creare la build dal sorgente; ci sono un po' di problemi con la repository ufficiale, in questa fork ci sono alcuni aggiustamenti
  - Il file di requirements è stato aggiornato, seguendo questa [pull request](https://github.com/nerfstudio-project/gsplat/pull/814)
  - Era necessario aggiungere un file `__init__.py` nella cartella `examples/datasets/` altrimenti non trovava il modulo

Innanzitutto, abilitare gli strumenti di sviluppo C++ invocando il seguente script:

    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"

Dopodiché, si può clonare la repository e fare la build della libreria:

    git clone --recursive git@github.com:GiusCat/gsplat.git
    cd gsplat
    set DISTUTILS_USE_SDK=1
    pip install .

Infine, si possono installare tutte le altre dependencies:

    cd examples
    pip install -r requirements.txt

### Fix errore pycolmap

Su Windows è presente un errore in una dependency, legato a differenze nella logica di struct unpacking; per risolvere serve eseguire i seguenti comandi (viene installata una fork che risolve il problema):

    pip uninstall pycolmap -y
    pip install git+https://github.com/mathijshenquet/pycolmap

- TODO: mettere la dependency giusta direttamente in `requirements.txt`

### [Opzionale] Convertire video in immagini

Prima di lanciare COLMAP, è necessario avere una serie di immagini; se si ha un video, bisogna estrarre un buon numero di frame:

    python examples\video2imgs.py --video_path <path_to_video> --output_dir <path_to_images> --fps <num_fps>

### Run COLMAP

First, define the required environment variables and create the output folder:

set COLMAP_PATH=<Path to installed colmap.bat>
set DATA_PATH=<Path to dataset folder, e.g., plush-dog>
set IMAGE_PATH=%DATA_PATH%\images
set DB_PATH=%DATA_PATH%\colmap.db
set SPARSE_PATH=%DATA_PATH%\sparse

mkdir %SPARSE_PATH%

### Run GSplat

Se tutto funziona, far partire il training

python simple_trainer.py default ^
--absgrad --grow_grad2d 8e-4 ^
--eval_steps -1 ^
--data_factor 4 ^
--save_ply ^
--max_steps 7000 ^
--ply_steps 7000 ^
--data_dir C:\Users\user\Downloads\gaussian_bin_2 ^
--result_dir C:\Users\user\Downloads\gaussian_bin_2\splat

--ply_steps 25000 ^ -> check di poter omettere questo

### Test vari

216 images, max_steps=15000, data_factor=4 -> 07:32
555 images, max_steps=30000, data_factor=4 -> 23:00 circa mi pare
341 images, max_steps=30000, data_factor=4 (video 4k60) -> 22:21