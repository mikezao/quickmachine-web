const fetch = require('node-fetch');

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const GITLAB_TOKEN = process.env.GITLAB_TRIGGER_TOKEN;
    const GITLAB_PROJECT_ID = process.env.GITLAB_PROJECT_ID;
    const GITLAB_REF = process.env.GITLAB_REF || 'main';

    if (!GITLAB_TOKEN || !GITLAB_PROJECT_ID) {
        context.res = {
            status: 500,
            body: "GitLab trigger environment variables not set on server."
        };
        return;
    }

    const { VM_NAME, VM_SIZE, OS_SKU } = req.body;

    if (!VM_NAME || !VM_SIZE || !OS_SKU) {
        context.res = {
            status: 400,
            body: "Missing required VM parameters: VM_NAME, VM_SIZE, OS_SKU"
        };
        return;
    }

    const triggerUrl = `https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/trigger/pipeline`;
    const formData = new URLSearchParams();
    formData.append('token', GITLAB_TOKEN);
    formData.append('ref', GITLAB_REF);
    formData.append('variables[VM_NAME]', VM_NAME);
    formData.append('variables[VM_SIZE]', VM_SIZE);
    formData.append('variables[OS_SKU]', OS_SKU);

    try {
        const response = await fetch(triggerUrl, {
            method: 'POST',
            body: formData
        });

        const jsonResponse = await response.json();

        if (!response.ok) {
            throw new Error(`GitLab API responded with status: ${response.status} - ${JSON.stringify(jsonResponse)}`);
        }
        
        context.res = {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
            body: jsonResponse
        };

    } catch (error) {
        context.log.error('Failed to trigger pipeline:', error);
        context.res = {
            status: 500,
            body: { error: error.message }
        };
    }
};