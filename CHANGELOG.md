# `k3s-ansible` changelog (`k3s.orchestration`)

## 1.2.0

### PRs Merged

- Move k3s version control into testing CI (#523)
- Add openrc support to k3s_server role (#521)
- Add a notoken test (#520)
- Remove template from k3s_upgrade role (#519)
- Fix airgap for agents (#518)
- Testing rework for correct validation (#516)
- fix: idempotency and control flow improvements (#514)
- fix: use correct variable for k3s old token for agents in upgrade.yml (#513)
- Add nftables configuration for K3s on Arch Linux (#511)
- No server templates in k3s_server role (#509)
- Fix the 'Save the existing K3s token if needed' task (#503)
- Install airgap selinux rpms when avaliable (#500)
- Fix raspberrypi boot.txt - update regex for cgroup config (#499)
- Provide configurable server/agent group names for airgap role (#497)
- Add HA Server test (#491)
- Support openrc systems on agent nodes, added openrc test matrix (#489)
- Fix boot lint (#488)
- Fix typo in README regarding requirements file (#487)
- Update Archlinux ARM on Raspberry PI 5 (#486)
- Ensure agents are upgraded correctly (#484)
- fix: token compare tasks in k3s_server and k3s_agent roles (#481)

For a full list of commits see [diff between 1.1.1 and 1.2.0](https://github.com/k3s-io/k3s-ansible/compare/1.1.1...1.2.0).

Thanks to all community contributors including: cioionut, gillouche, jon-stumpf, knpwrs, laszlojau, lexfrei, morgaesis, paulkarabilo, ppascente!

## 1.1.1

### PRs Merged

- Improve capture regex for k3s-agent service replacement (#470)
- Add ability to move kubeconfig to control node on demand (#467)
- refactor(prereq): use ansible_os_family for broader RHEL support (#469)
- fix(upgrade): Implement airgap support for the upgrade flow. (#465)
- Refactor task to add compatibility with cmdline changes on ubuntu 25 (#461)
- feat: add ufw allow inter-node ports (#460)
- Pin python to 3.13 for ansible 2.19 support (#462)
- allow for opt_tls_san to be undefined, since it's optionally defined (#456)
- Reduce run noise (#450)

For a full list of commits see [diff between 1.1.0 and 1.1.1](https://github.com/k3s-io/k3s-ansible/compare/1.1.0...1.1.1).

Thanks to all community contributors including: fch-aa, lufisaal, PhilThurston, rpressiani, softplus10, too-gee, triplepoint!

## 1.1.0

### PRs Merged

- Distribute multiple image archives (#428) 
- Don't update_cache if airgapped (#430) 
- Add missing RHEL 10 kernel module (#431) 
- Bump version in galaxy.yml (#432) 
- Inject installation envs for install script (#433) 
- docs: describe adding collection to requirements.yaml (#438) 
- Correct indentation for k3s_upgrade command (#439) 
- Fix ipv4 lookup for firewalld (#440) 
- Automatically inject tls-san when api_endpoint differs from hostname (#434)
- Remove agent jinja template (#442)
- Consolidate server templates into a single one (#443) 

For a full list of commits see [diff between 1.0.1 and 1.1.0](https://github.com/k3s-io/k3s-ansible/compare/1.0.1...1.1.0).

Thanks to all community contributors including: Claiyc, dbanetto, felix-seifert, guiand888, tambel, vd-rd!

## 1.0.0
Initial Release
