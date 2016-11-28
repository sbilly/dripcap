<log-view>
  <h2>New session</h2>
  <p>
    <select name="interface">
      <option each={ parent.interfaceList } if={ link===1 } value={ encodeURI(id) }>{ name }</option>
    </select>
  </p>
  <p>
    <input type="text" name="filter" placeholder="filter (BPF)">
  </p>
  <p>
    <label>
      <input type="checkbox" name="promisc">
      Promiscuous mode
    </label>
  </p>
  <p>
    <input type="button" name="start" value="Start" onclick={ parent.start }>
  </p>
</log-view>
