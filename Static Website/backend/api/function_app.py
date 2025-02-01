#Replace the HTTP Trigger pre-made code with your own Azure Function
#This comment was put here to test the backend.main.yml Github workflow
import azure.functions as func
import logging
import json

app = func.FunctionApp()

@app.function_name(name="GetResumeCount")
@app.route(route="GetResumeCount")
#Cosmos DB Input Trigger
@app.cosmos_db_input (arg_name="documents", 
                      database_name="CounterDB",
                      container_name="Counter",
                      id="1",
                      partition_key="1",
                      connection="MyAccount_COSMOSDB" #Connection string set in local.settings.json
                      )
#Cosmos DB Output Trigger
@app.cosmos_db_output (arg_name="documentsOut",
                       database_name="CounterDB",
                       container_name="Counter",
                       connection="MyAccount_COSMOSDB",
                       create_if_not_exists=True,
                       partition_key="1"
                      )
def getAndUpdateCount(req: func.HttpRequest, documents: func.DocumentList, documentsOut: func.Out[func.Document]) -> func.HttpResponse:
      if not documents:
        doc_dict = {'id': "1", 'count': 1}
        documentsOut.set(doc_dict)
        return func.HttpResponse(
        json.dumps(doc_dict),
        mimetype="application/json",
        )
      
      update_count = documents[0]

      update_count['count'] = update_count['count'] + 1

      documentsOut.set(update_count)

      return func.HttpResponse(
          json.dumps(documents[0].to_dict()),
          mimetype="application/json",
      )