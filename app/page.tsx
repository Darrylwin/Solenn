import {Footer} from "@/components/layout/footer";
import {Header} from "@/components/layout/header";
import {Download} from "@/components/sections/download";
import {Guarantees} from "@/components/sections/guarantees";
import {Hero} from "@/components/sections/hero";
import {HowItWorks} from "@/components/sections/how-it-works";
import {Plans} from "@/components/sections/plans";
import {Screens} from "@/components/sections/screens";
import {TheLies} from "@/components/sections/the-lies";
import {getLatestRelease, resolveDownload} from "@/lib/release";
import {getScreens} from "@/lib/screens";
import {NAV} from "@/lib/site";

export default async function HomePage() {
    const release = await getLatestRelease();
    const screens = getScreens();
    const nav = NAV.filter((item) => item.id !== "screens" || screens.length > 0);

    return (
        <>
            <Header nav={nav}/>
            <main id="main">
                <Hero download={resolveDownload(release)}/>
                <HowItWorks/>
                <TheLies/>
                <Screens screens={screens}/>
                <Plans/>
                <Guarantees/>
                <Download release={release}/>
            </main>
            <Footer/>
        </>
    );
}
