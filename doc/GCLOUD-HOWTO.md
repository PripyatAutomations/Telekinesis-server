* Create a project netrig
* Enable IAM, tts, translation services

* Create access keys
	gcloud auth application-default login
	gcloud auth login
	gcloud config set project netrig-1234567

* setup quotas
	gcloud auth application-default set-quota-project netrig-1234567
