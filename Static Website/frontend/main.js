window.addEventListener('DOMContentLoaded', (event) => {
    getVisitCount();
})

const functionApiUrl = 'https://getresumecount-python.azurewebsites.net/api/GetResumeCount?code=mswwyiSFbEcogvOlMgeeugEggvstjNGBW9zcW7Wnb1K6AzFu4WCnmg%3D%3D'; //Get from Functions Default Key
// const functionApi = 'http://localhost:7071/api/GetResumeCount'; //Azure fuction local testing goes here

const getVisitCount = () => {
    let count = 30;
    fetch(functionApi).then(response => {
        return response.json()
    }).then(response =>{
        console.log("Website called function API.");
        count = response.count;
        document.getElementById("counter").innerText = count;
    }).catch(function(error){
        console.log(error);
    });
    return count;
}