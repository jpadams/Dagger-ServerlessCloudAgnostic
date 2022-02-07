package Create

import (
	"alpha.dagger.io/dagger"
    "alpha.dagger.io/os"
    "github.com/barbo69/AzureServerless/Azure/Login"
)

#create: {
    // Azure Config
	config: Login.#Config

    // Function name
    name: string & dagger.#Input

    // Function location
    location: string & dagger.#Input 

    // ResourceGroup name
    resourceGroup: name: string & dagger.#Input

    // Storage name
    storage: name: string & dagger.#Input

    // Function Id
	id: string & dagger.#Output

    ctr: os.#Container & {
        image: Login.#CLI & {
			"config": config
            "version": "latest"
		}

        always: true

        command: """
            az functionapp create --resource-group "$AZURE_DEFAULTS_GROUP" --consumption-plan-location "$AZURE_DEFAULTS_LOCATION" --runtime node --runtime-version 12 --functions-version 3 --name "$AZURE_DEFAULTS_FUNCTION" --storage-account "$AZURE_DEFAULTS_STORAGE"
            az functionapp show -n "$AZURE_DEFAULTS_FUNCTION" --query "id" -o json | jq -r . | tr -d "\n" > /functionId
        """
        
        env: {
            AZURE_DEFAULTS_GROUP:    resourceGroup.name
            AZURE_DEFAULTS_STORAGE:  storage.name
            AZURE_DEFAULTS_LOCATION: location
            AZURE_DEFAULTS_FUNCTION: name
        }
    }

    id: ({
		os.#File & {
			from: ctr
			path: "/functionId"
		}
	}).contents
}