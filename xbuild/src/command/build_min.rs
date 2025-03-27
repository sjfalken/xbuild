use std::path::Path;
use appbundle::AppBundle;
use xcommon::{Zip, ZipFileOptions};
use crate::{BuildEnv, Format, Platform};
use crate::cargo::CrateType;
use crate::download::DownloadManager;
use crate::task::TaskRunner;

pub fn build_min(env: &BuildEnv) -> anyhow::Result<()> {
    let platform_dir = env.platform_dir();
    std::fs::create_dir_all(&platform_dir)?;

    let mut runner = TaskRunner::new(3, env.verbose());

    runner.start_task("Fetch precompiled artifacts");
    let manager = DownloadManager::new(env)?;
    if !env.offline() {
        manager.prefetch()?;
        runner.end_verbose_task();
    }

    runner.start_task(format!("Build rust `{}`", env.name));
    let bin_target = env.target().platform() != Platform::Android;
    let has_lib = env.root_dir().join("src").join("lib.rs").exists();
    if bin_target || has_lib {
        if env.target().platform() == Platform::Android && env.config().android().gradle {
            crate::gradle::prepare(env)?;
        }
        for target in env.target().compile_targets() {
            let arch_dir = platform_dir.join(target.arch().to_string());
            let mut cargo = env.cargo_build(target, &arch_dir.join("cargo"))?;
            if !bin_target {
                cargo.arg("--lib");
            }
            cargo.exec()?;
        }
        runner.end_verbose_task();
    }

    // runner.start_task(format!("Create {}", env.target().format()));
    // match env.target().platform() {
    //     Platform::Ios => {
    //         let _target = env.target().compile_targets().next().unwrap();
            // let arch_dir = platform_dir.join(target.arch().to_string());
            // std::fs::create_dir_all(&arch_dir)?;
            // let mut app = AppBundle::new(&arch_dir, env.config().ios().info.clone())?;
            // if let Some(icon) = env.icon() {
            //     app.add_icon(icon)?;
            // }
            // let main = env.cargo_artefact(&arch_dir.join("cargo"), target, CrateType::Bin)?;
            // app.add_executable(&main)?;
            // if let Some(provisioning_profile) = env.target().provisioning_profile() {
            //     app.add_provisioning_profile(provisioning_profile)?;
            // }
            // if let Some(assets_car) = env.config().ios().assets_car.as_ref() {
            //     app.add_file(assets_car, "Assets.car".as_ref())?;
            // }
            // app.finish(env.target().signer().cloned())?;
            // if env.target().format() == Format::Ipa {
            //     let app = arch_dir.join(format!("{}.app", env.name()));
            //     let out = arch_dir.join(format!("{}.ipa", env.name()));
            //     let mut ipa = Zip::new(&out, false)?;
            //     ipa.add_directory(
            //         &app,
            //         &Path::new("Payload").join(format!("{}.app", env.name())),
            //         ZipFileOptions::Compressed,
            //     )?;
            //     ipa.finish()?;
            // }
    //     },
    //     _ => unimplemented!(),
    // }
    // runner.end_task();

    Ok(())
}
