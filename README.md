# Documentation for the ACH_APP developed by William M. Smith

# Installation and serving
Download all source files. Be sure to have Node.js installed along with node package manager (npm). Navigate to the folder via Bash or alternative shell and run `npm install` to get all of the modules. 

To serve the app locally, run `npm start` to open the app on localhost (should default to localhost:3000)

# GIT Instrucitions
Create a github account if you do not have one. Clone the VCH_APP repository to your dekstop. If needed, set up github pages:

```
git init
git remote add origin https://github.com/gitname/gitappname.git
npm run deploy

git add . 
git commit -m "Write a message"
git push origin master

```

This provides source control and serves the app to be run online. 

Go to settings in the git repository, navigate to GitHub  Pages, and select source as `gh-pages branch`. It should then show the the URL that is published. 

# API 
The data transfer to RedCap is done via Amazon Web Services Lambda functions. It exposes a public API so be very careful when sharing it as if there are too many function calls, you can be charged money. For the purposes of this app, the API is exposed to client side upon inspection, but should not be a problem with patients. Do monitor this for any unusual behavior, all keys are encrypted, but anyone can push to the API which will trigger the function even if the data is not accepted. 

# Transfering Files
When tranfering data, NEVER upload or transfer the `node-modules` file. Always exclude the folder when uploading and transfering. 

# React
The application is built in React. React has constantly rendering when changes are made and consists of components to be explained later. There is a combination of CSS, HTML, and Javascript that work together with packages for functionality. 

# Redux
Redux maintains a state store that contains variables across components. You must define your functions in the `actions` files. You then must update the `reducer` with the new data parameter as well as the function that takes the `type, payload` and updates the store. Essentially you must:
1. create a new action 
2. update the reducer store and switch case
3. connect the new function and data parameter to your files:

```
const mapStateToProps = state => ({
  data: state.data,
})

const mapDispatchToProps = dispatch => ({
  add_response_q_1: (element) => dispatch(add_response_q_1(element)),
})

...

export default connect(mapStateToProps, mapDispatchToProps)(TrialQ);

```

See code for details. 

# Router 
Router sets up "URLs" within the app so that it knows what components to redirect to. React is a single page application so there must be a system in place to choose which component will be presented. Routes allow for us to redirect from one component to another, choose the component based on the URL, and more. Please look at Routes.js for more information. 

When updating the route:
    You must import the component and then add a new route in Routes.js. 

# VisualQuest, Stim, and Quest Files 
Visual Quest contains a sample test file for testing the QUEST functions as well as the processing of data for gumbel intensities. You can import:
 `import { process_data } from "../VisualQuest.js"`
and run `process_data(q1, q2)` which returns a structure: 

```
returnStruct = {
        intensities: [],
        parameters: [],
        beta: 0,
    }
```

Stim.js exports functions `createStim() and createGabor( stim, contrast )`. createStim() creates a new stimulus variable that will be used in the visual trial. The createGabor( stim, contrast ) essentially makes a new layer with the given contrast that causes the banding to occur within the noise. 

Quest.js includes most of the functions in the Quest package for matlab. For more information, visit: https://github.com/Psychtoolbox-3/Psychtoolbox-3. Look at the Quest.js file for parameters. For example, you can import the functions as:

```
import { sumVector, QuestPdf, QuestRecompute, QuestCreate, QuestMean, QuestSd, QuestQuantile, QuestUpdate, PAL_Gumbel, QuestSimulate } from "./Quest.js"

```
# QUEST 
Quest will take the user input and then calculate the next contrast to be outputted for the user to respond to. This is done by creating `q` objects that contain a set of parameters set by the administrators. These `q` objects will then be recomputed and their Quantiles taken for use with the next trial. More information can be found in the PsychToolbox package for Matlab. The JavaScript translation was done by William Smith and was tested to be accurate to 14+ decimal places with the Matlab equivalent. 

# Basic Components 
The components have listeners that check if the `Q` or `E` key were pressed as well as keys `1-5`. Q is 'YES' and E is 'NO'. 

The Welcome component welcomes the user and prompts them to press Q to continue. The Instructions component prompts the user to press Q to continue after telling them what to do via text. The NotFound sends a generic error message for broken links. 

# Main Functional Components
The Trial components consist of functions from Stim.js, Quest.js, VisualQuest.js, and redux actions. There is a state store that contains variables to be changed during function `create_noise`. 

`create_noise(audioContext)` will take in a audioContext object to be used with `beep(amp, freq, ms, audioContext)` that triggers the tone for the trial. A package caleld `Simplex-Noise` is then used to create an object that will be placed on a `react canvas` for random noise generation. Quest is initialized with certain parameters and q objects are created: `var q_1 = QuestCreate(tGuess, tGuessSd, pThreshold, beta, delta, gamma, grain, range);`

Simuli are made: 
```
var stim = createStim();
var stimulus_blank = createGabor(stim, 0);
```

`vis_quest()` is a function with `create_noise` that will run the `window.requestAnimationFrame` which syncs to hardware. This runs a standard 60 frames per second (more or less with hardware). Essentially, a randomly generating noise sequence of simplex-noise is created with a crosshair over it. A certain intervals, a Gabor stimulus with a certain contrast appears within the nosie (interweaved). This then triggers a window for the user to press `Q or E` and `1-5` for their response that they CAN or CANNOT see it and how CONFIDENT they are. JavaScript operates matrices with RGB and opacity values per pixel. 

There are windows of time for input. If the specific input is not collected (response AND rating), then it will throw away the data and redo the contrast trial. This image data is then put on the canvas for the user to see and the image reruns. 

Q data is updated after every successful response: `          q_1 = QuestUpdate(q_1, [that.state.contrast_array_q_1[that.state.contrast_array_q_1.length - 1]], [that.state.responses_q_1[that.state.responses_q_1.length - 1]]);` 
At the very end, there will be a push to redux so that the data is maintained across component changes. 

# Key Functions
The app listens for key presses and then reacts accordingly. This trigers the time_window as well as a continue property that will end the trial if needed. This is specific to the q variable (q1 or q2) and allows for instant collection of response data since they are listening for any interrupts. It changes the state of the component variables and is integral to the app running smoothyl/correctly. 

# React Canvas
Canvas essentially puts a sheet on the html that will later be injeted with an image or pixel data. This is what is used to push the random noise to the screen so that there is a constant stream  like a video. 

```
<header className="TrialQ-header">
          <canvas id="c" width="256" height="256"
            style={{ zIndex: "0", position: "fixed", left: "25%", width: '50%', height: 'auto' }}></canvas>
          <canvas id="c2" width="256" height="256"
            style={{ zIndex: "1", position: "fixed", left: "25%", width: '50%', height: 'auto' }}></canvas>
        </header>
```

# REDCAP and Complete
The application takes from redux and then puts the information to be sent to the AWS API that then routes it to REDCAP. There is are attached user_id and data fields whereas data is simply a JSON'd version of the data in Redux. The AWS lambda function contains the REDCAP token in the environment variable field as to abstract away to back end. This makes it that the public cannot see or have access to the REDCAP database. However, since the API is public, people can invoke the API which may cause incorrect records (if they send the JSON correctly).

```
var axios = require('axios')

     axios.post("API_URL_HERE", 
     {
        data: "{[1], [1, 1, 1, 1, 1], [0, 0, 0, 0, 0], [1.5, 1.3, 1.2, 1.0, 1.5], [0.5, 1, 1.5, 1, 1], [0.5, 0.5, 0.75, 1, 1], [0.8, 1, 0.7, 0.6, 0.5], {[1, 2, 3], [0.5, 0.6, 0.7], [0.5, 0.6, 0.7]}}  ",
     }
     ).then(function (response) {
      console.log(response);
    })
    .catch(function (error) {
      console.log(error);
    });

    axios.delete("API_URL_HERE", { data: {record_id: 1 }}).then(function (response) {
        console.log(response);
      })
      .catch(function (error) {
        console.log(error);
      });

```

# Conclusions
The app guides the user through a series of pages that will then set up `q` objects that take their responses and return new contrasts for the next trials. The data is then processed to analyze the user's performance and responses. All data is saved to Redux which is later pushed to the API towards REDCAP. The application allow for data collection and analysis to test the conditioning of certain patients. 
