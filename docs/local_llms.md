# Attaching BCM-hosted LLMs to agentic coding harnesses

BCM now hosts a few large language models (LLMs) that can be used with agentic coding harnesses and are compliant for use with confidential BCM data and PHI data. I provide instructions below for attaching these models to [OpenCode](https://opencode.ai/), an open-source coding harness which is provider-agnostic (you can use models provided by Anthropic, OpenAI, Google, etc). However, you can also attach local models to Claude Code and Codex if you prefer to use those harnesses - the exact steps for setting up models for local use will change but the general principles should be the same. 

## Obtain API Key

The chatBCM team serves the LLMs via LiteLLM; you can request an API key to use any of the models they offer. To obtain an API key, you can [email the chatBCM team](mailto:chatBCM@bcm.edu) and request an API key.

## Setting up OpenCode

* **Install OpenCode on your machine**. The tool began as a TUI, but there is now also a desktop GUI. The TUI will work even on servers and is well-designed; I haven't tried the GUI yet. Instructions for installing either the TUI or GUI can be found [here](https://opencode.ai/download).

* **Add local model information in config**. The following should be written to your JSON config file at the user level, which will be stored at `~/.config/opencode/opencode.json`. This file may not exist or may be empty if you haven't configured OpenCode yet; simply write the following at the above file path. It tells OpenCode to use the LiteLLM provider and the models that can be accessed. Of note, should the chatBCM team change the models they host, you will need to update this file to reflect the new model names.

   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "provider": {
       "litellm": {
         "package": "@opencode/ai/providers/openai-compatible",
         "name": "LiteLLM",
         "settings": {
           "baseURL": "https://chatbcm.bcm.edu/litellm/v1"
         },
         "models": {
           "nemotron-3-nano:30b": {
             "name": "Nemotron"
           },
           "gpt-oss:120b": {
             "name": "GPT-OSS"
           },
           "gemma4:26b": {
             "name": "Gemma"
           }
         }
       }
     }
   }
   ```

* **Connect LiteLLM to OpenCode**. *These instructions assume you downloaded the TUI*. Open OpenCode (`opencode` in your terminal) and enter `/connect`. Within the search field, type `LiteLLM` and select it. You will be prompted to enter an API key; enter the API key you obtained from the chatBCM team.

* **Choose a model**. Enter `/model` and select one of the BCM-hosted models. You will see that models other than those hosted by BCM are also available, but you should only use the BCM-hosted models for confidential data. You can tell which are BCM hosted because they will have the `LiteLLM` provider listed. If you'd like, you can also edit the names in the JSON config file as well (e.g. change `Nemotron` to `Nemotron-BCM`).