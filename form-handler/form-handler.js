function handleForm() {
  const inputObject = JSON.parse(Host.inputString());
  inputObject.source = `CodeBEAM 2024 LIIVE!!`;
  const request = {
    method: "POST",
    url: 'https://eoqkynla62cbht1.m.pipedream.net'
  }
  const response = Http.request(request, JSON.stringify(inputObject));
  if (response.status != 200) throw new Error(`Got non 200 response ${response.status}`)
  Host.outputString(JSON.stringify(inputObject));
}

module.exports = { handleForm };