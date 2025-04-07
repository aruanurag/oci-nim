# Nvidia NIM on OCI Compute

This guide is a walkthrough of steps required to deploy a [Nvidia NIM](https://developer.nvidia.com/nim?sortBy=developer_learning_library%2Fsort%2Ffeatured_in.nim%3Adesc%2Ctitle%3Aasc) on a OCI instance. FOrthis guide the NIM being deployed is the [deepseek-r1-distill-llama-8b](https://build.nvidia.com/deepseek-ai/deepseek-r1-distill-llama-8b) model.

##  Steps:

1. Login/signup [here](https://build.nvidia.com/explore/discover?ncid=no-ncid) and get a api key.
2. Update  [script](/oci-compute/script.sh) with the api key from step 1.
3. Follow the steps [here](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/launchinginstance.htm) to create a oci instance. Use the following configuration

    - **Shape**: VM.GPU.A10.2
    - **Image**: Oracle-Linux-9.5-Gen2-GPU-2025.03.18-0
    - **Initialization script**: [script](/oci-compute/script.sh)
    - Use a private subnet
    - **Custom Boot Volume Size**: 500 GB
4. **Testing Setup** Testing can be done using
    - **Cloud Shell**  Use the [blog](https://blogs.oracle.com/oracleuniversity/post/access-compute-instances-oracle-cloud-shell) to get private access to the Instance.
    - **Load Balancer**  Setup a Public facing load balancer. One [example](https://docs.oracle.com/en/learn/oci-network-lb-with-instances/index.html)

5. **Testing** 
    - **Cloud Shell** - Use the following command with the private IP of the instance
        ```
        curl -X 'POST' \
        'http://<PrivateIp>:8000/v1/chat/completions' \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{
            "model": "deepseek-ai/deepseek-r1-distill-llama-8b",
            "messages": [{"role":"user", "content":"Which number is larger, 9.11 or 9.8?"}],
            "max_tokens": 64
        }'
        ```
    - **Load Balancer** - Use the Public Ip of the LB to test using curl or a client such as [Postman](https://www.postman.com/downloads/)

6. **Integration**  Use code snippets from [here](https://build.nvidia.com/deepseek-ai/deepseek-r1-distill-llama-8b) to integrate with you application.
    ```
    from openai import OpenAI

        client = OpenAI(
        base_url = "https://<Your IP>/v1",
        api_key = "$API_KEY_REQUIRED_IF_EXECUTING_OUTSIDE_NGC"
        )

        completion = client.chat.completions.create(
        model="deepseek-ai/deepseek-r1-distill-llama-8b",
        messages=[{"role":"user","content":""}],
        temperature=0.6,
        top_p=0.7,
        max_tokens=4096,
        stream=True
        )

        for chunk in completion:
        if chunk.choices[0].delta.content is not None:
            print(chunk.choices[0].delta.content, end="")
    ```