*** Settings ***
Documentation    Minimal test for the CUDA image
Resource         ../../Resources/ODS.robot
Resource         ../../Resources/Common.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterHubSpawner.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterLabLauncher.robot
Resource         ../../Resources/Page/ODH/JupyterHub/GPU.resource
Library          JupyterLibrary
Suite Setup      Verify CUDA Image Suite Setup
Suite Teardown   End Web Test
Force Tags       JupyterHub


*** Variables ***
${NOTEBOOK_IMAGE} =         minimal-gpu
${EXPECTED_CUDA_VERSION} =  11.4


*** Test Cases ***
Verify CUDA Image Can Be Spawned With GPU
    [Documentation]    Spawns CUDA image with 1 GPU and verifies that the GPU is
    ...    not available for other users.
    [Tags]  Sanity    Tier1
    ...     Resources-GPU
    ...     ODS-1141    ODS-346    ODS-1359
    Pass Execution    Passing tests, as suite setup ensures that image can be spawned

Verify CUDA Image Includes Expected CUDA Version
    [Documentation]    Checks CUDA version
    [Tags]  Sanity    Tier1
    ...     Resources-GPU
    ...     ODS-1142
    Verify Installed CUDA Version    ${EXPECTED_CUDA_VERSION}

Verify PyTorch Library Can See GPUs In Minimal CUDA
    [Documentation]    Installs PyTorch and verifies it can see the GPU
    [Tags]  Sanity    Tier1
    ...     Resources-GPU
    ...     ODS-1144
    Verify Pytorch Can See GPU    install=True

Verify Tensorflow Library Can See GPUs In Minimal CUDA
    [Documentation]    Installs Tensorflow and verifies it can see the GPU
    [Tags]  Sanity    Tier1
    ...     Resources-GPU
    ...     ODS-1143
    Verify Tensorflow Can See GPU    install=True


*** Keywords ***
Verify CUDA Image Suite Setup
    [Documentation]    Suite Setup, spawns CUDA img with one GPU attached
    ...    Additionally, checks that the number of available GPUs decreases
    ...    after the GPU is assigned.
    Begin Web Test
    Launch JupyterHub Spawner From Dashboard
    Spawn Notebook With Arguments  image=${NOTEBOOK_IMAGE}  size=Default  gpus=1
    # Verifies that now there are no GPUs available for selection
    @{old_browser} =  Get Browser Ids
    Launch Dashboard    ${TEST_USER2.USERNAME}    ${TEST_USER2.PASSWORD}    ${TEST_USER2.AUTH_TYPE}
    ...    ${ODH_DASHBOARD_URL}    ${BROWSER.NAME}    ${BROWSER.OPTIONS}
    Launch JupyterHub Spawner From Dashboard    ${TEST_USER_2.USERNAME}    ${TEST_USER.PASSWORD}
    ...    ${TEST_USER.AUTH_TYPE}
    ${maxSpawner} =    Fetch Max Number Of GPUs In Spawner Page
    Should Be Equal    ${maxSpawner}    ${0}
    Close Browser
    Switch Browser  ${old_browser}[0]
