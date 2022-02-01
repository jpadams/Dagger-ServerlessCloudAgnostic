package function

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/gcp"
	"alpha.dagger.io/os"
	"github.com/gcpServerless/configServerless"
)

// The runtimes are copied from https://cloud.google.com/functions/docs/concepts/exec
// If the list would come to change please submit an issue or a pull request to integrate it
#Runtime: "nodejs16" | "nodejs14" | "nodejs12" | "nodejs10" | "nodejs8" | "nodejs6" | "python39" | "python38" |
	"python37" | "go116" | "go113" | "go111" | "java11" | "dotnet3" | "ruby27" | "ruby26" | "php74"

#Function: {

	config:  configServerless.#Config
	name:    string
	runtime: #Runtime

	// Directory containing the files for the cloud functions
	source: dagger.#Input & {dagger.#Artifact}

	container: os.#Container & {

		image: gcp.#GCloud & {
			"config": config.gcpConfig
		}
		always: true
		mount: "/src": from: source
		env: {
			NAME:    name
			RUNTIME: runtime
		}
		command: #"""
			gcloud functions deploy ${NAME} --runtime ${RUNTIME} --source /src --trigger-http --allow-unauthenticated
			"""#
	}
}
