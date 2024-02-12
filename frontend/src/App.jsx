import "./App.css";
import Homepage from "./Pages/Homepage";
import { Route } from "react-router-dom";
import Chatpage from "./Pages/Chatpage";
import axios from "axios";

axios.defaults.baseURL = `${import.meta.env.VITE_API_BACKEND_URL?import.meta.env.VITE_API_BACKEND_URL:""}`;

function App() {
  return (
    <div className="App">
      <Route path="/" component={Homepage} exact />
      <Route path="/chats" component={Chatpage} />
    </div>
  );
}

export default App;
