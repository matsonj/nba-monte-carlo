<GithubStarCount user='matsonj' repo='nba-monte-carlo'/>
<br>

## mdsinabox - a sports monte carlo simulator

Welcome to the [NBA monte carlo simulator](https://github.com/matsonj/nba-monte-carlo) project. Evidence is used as the as data visualization & analysis part of [MDS in a box](https://www.dataduel.co/modern-data-stack-in-a-box-with-duckdb/).

This project leverages duckdb, make, dbt, and evidence and builds and runs about once per day in a github action. You can learn more about this on [this page](/about).

## [NBA Model](/nba)

## [NFL Model](/nfl)

## [NCAA Football Model](/ncaaf)

## Want to track what I am cooking up next? Join the email list.

<script>
    let email = "";
    let form_id = "1FAIpQLSeiRdk9saFMRfrgV6k7izrs0SfmpptVd4M6I3tUH9jAumleKQ";
    let src = "mdsinabox-home"
    let submitted = false;
    let buttonValue = "";


        // https://docs.google.com/forms/d/e/1FAIpQLSeiRdk9saFMRfrgV6k7izrs0SfmpptVd4M6I3tUH9jAumleKQ/viewform?usp=pp_url&entry.1761363524=Email@email.com&entry.1932146161=Yourmom

    $: prefilledLink = `https://docs.google.com/forms/d/e/${form_id}/formResponse?usp=pp_url&entry.1761363524=${email}&entry.1932146161=${src}&submit=Submit`;

 async function handleSubmit() {
    try {
        const response = await fetch(prefilledLink);
        if (response.status === 200) {
            buttonValue = "Submitted";
        } else {
            buttonValue = "Error";
        }
    } catch (error) {
        console.error('Error:', error);
        buttonValue = "Error";
    } finally {
        submitted = true;
    }
}
</script>

<label>Email
    <input type="email" placeholder="name@email.com" bind:value="{email}" />
</label>
<br>

<button class="submit-button" on:click="{handleSubmit}" disabled="{!email || submitted}">
    {#if submitted}
        Submitted
    {:else if buttonValue === 'Failed'}
        Failed
    {:else}
        Submit
    {/if}
</button>

<style>
    .submit-button {
        border-radius: 8px;
        background-color: lightgrey;
        border: none;
        color: black;
        padding: 2px 6px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-size: 14px;
        margin: 4px 2px;
        cursor: pointer;
    }
</style>

<br>
The current value of prefilledLink is: `{prefilledLink}`
